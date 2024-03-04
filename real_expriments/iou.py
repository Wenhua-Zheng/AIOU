import math
import torch


class IoU_Cal:
    ''' pred, target: x0,y0,x1,y1
        monotonous: {
            None: origin
            True: monotonic FM
            False: non-monotonic FM
        }
        momentum: The momentum of running mean (This can be set by the function <momentum_estimation>)'''
    iou_mean = 0.9
    conf_mean = 0.9
    # iou_mean and conf_mean The update speed
    momentum = 1 - pow(0.05, 1 / (688 * 3))  # 1 - pow(0.05, 1 / batches * 3)
    _is_train = True

    @classmethod
    def momentum_estimation(cls, n, t):
        """
        n: Number of batches per training epoch
        t: The epoch when mAP's ascension slowed significantly
        """
        time_to_real = n * t
        cls.momentum = 1 - pow(0.05, 1 / time_to_real)
        return cls.momentum

    def __init__(self, pred, target, anchors, psobj, iou_focal_loss='based', conf_focal_loss='based'):
        self.pred, self.target, self.anchors, self.psobj = pred, target, anchors, psobj
        self.iou_focal_loss, self.conf_focal_loss = iou_focal_loss, conf_focal_loss
        self.focal_type = ['based', 'monotonous', 'non_monotonous', 'adaptive']
        self._fget = {
            # x,y,w,h
            'pred_xy': lambda: (self.pred[..., :2] + self.pred[..., 2: 4]) / 2,
            'pred_wh': lambda: self.pred[..., 2: 4] - self.pred[..., :2],
            'target_xy': lambda: (self.target[..., :2] + self.target[..., 2: 4]) / 2,
            'target_wh': lambda: self.target[..., 2: 4] - self.target[..., :2],
            # x0,y0,x1,y1
            'min_coord': lambda: torch.minimum(self.pred[..., :4], self.target[..., :4]),
            'max_coord': lambda: torch.maximum(self.pred[..., :4], self.target[..., :4]),
            # The overlapping region
            'wh_inter': lambda: torch.relu(self.min_coord[..., 2: 4] - self.max_coord[..., :2]),
            's_inter': lambda: torch.prod(self.wh_inter, dim=-1),
            # The area covered
            's_union': lambda: torch.prod(self.pred_wh, dim=-1) +
                               torch.prod(self.target_wh, dim=-1) - self.s_inter,
            # The smallest enclosing box
            'wh_box': lambda: self.max_coord[..., 2: 4] - self.min_coord[..., :2],
            's_box': lambda: torch.prod(self.wh_box, dim=-1),
            'l2_box': lambda: torch.square(self.wh_box).sum(dim=-1),
            # The central points' connection of the bounding boxes
            'd_center': lambda: self.pred_xy - self.target_xy,
            'l2_center': lambda: torch.square(self.d_center).sum(dim=-1),
            # IoU
            'iou': lambda: 1 - self.s_inter / self.s_union,

            'l2_pred_wh': lambda: torch.square(self.pred[..., 2: 4] - self.pred[..., :2]),
            'l2_target_wh': lambda: torch.square(self.target_wh).sum(dim=-1),
            'l2_anchors_wh': lambda: torch.square(self.anchors[:]).sum(dim=-1),
            'conf': lambda: 1 - self.psobj
        }
        self._update(self)

    def __setitem__(self, key, value):
        self._fget[key] = value

    def __getattr__(self, item):
        if callable(self._fget[item]):
            self._fget[item] = self._fget[item]()
        return self._fget[item]

    @classmethod
    def train(cls):
        cls._is_train = True

    @classmethod
    def eval(cls):
        cls._is_train = False

    @classmethod
    def _update(cls, self):
        if cls._is_train: cls.iou_mean = (1 - cls.momentum) * cls.iou_mean + \
                                         cls.momentum * self.iou.detach().mean().item()

        if cls._is_train: cls.conf_mean = (1 - cls.momentum) * cls.conf_mean + \
                                          cls.momentum * self.conf.detach().mean().item()

    def _scaled_iou_loss(self, loss, alpha=1.9, delta=3):
        if self.iou_focal_loss not in self.focal_type:
            raise ValueError("Ensure iou_focal_type in {}", self.focal_type)
        # monotonous
        elif self.iou_focal_loss is self.focal_type[1]:
            beta = (1 - self.iou.detach()) / (1 - self.iou_mean)  # Suppression of low-quality samples
            loss *= beta.sqrt()
        # non_monotonous
        elif self.iou_focal_loss is self.focal_type[2]:
            beta = self.iou.detach() / self.iou_mean  # Suppression of high-quality samples
            divisor = delta * torch.pow(alpha, beta - delta)
            loss *= beta / divisor
        # adaptive
        elif self.iou_focal_loss is self.focal_type[3]:
            real_iou_mean = 1 - self.iou_mean
            # beta = self.iou.detach() / self.iou_mean  # Suppression of high-quality samples
            beta = (self.iou.detach() / self.iou_mean)/(1-(1*self.iou_mean))
            delta = max(1.5 * real_iou_mean * real_iou_mean + real_iou_mean + 0.9, 1.535)
            alpha = pow(0.5 / delta, -1 / (delta - 0.5))
            divisor = (real_iou_mean + 0.3) * delta * pow(alpha, beta - delta)
            loss *= beta / divisor
       
        return loss

    def _scaled_conf_loss(self, loss, alpha=1.9, delta=3):
        if self.conf_focal_loss not in self.focal_type:
            raise ValueError("Ensure conf_focal_type in {}", self.focal_type)
        # monotonous
        elif self.conf_focal_loss is self.focal_type[1]:
            beta = (1 - self.conf.detach()) / (1 - self.conf_mean)  # Suppression of low-quality samples
            loss *= beta.sqrt()
        # non_monotonous
        elif self.conf_focal_loss is self.focal_type[2]:
            beta = self.conf.detach() / self.conf_mean  # Suppression of high-quality samples
            divisor = delta * torch.pow(alpha, beta - delta)
            loss *= beta / divisor
        # adaptive
        elif self.conf_focal_loss is self.focal_type[3]:
            real_conf_mean = 1 - self.conf_mean
            # beta = self.conf.detach() / self.conf_mean  # Suppression of high-quality samples
            beta =(self.conf.detach() / self.conf_mean)/(1 - (1 * self.conf_mean))
            # beta = (0.7+(0.3*real_conf_mean)) * (self.conf.detach() / self.conf_mean) / (1 - (0.4 * self.conf_mean))
            delta = max(1.5 * real_conf_mean * real_conf_mean + real_conf_mean + 0.9, 1.535)
            alpha = pow(0.5 / delta, 1 / (0.5-delta))
            divisor = (real_conf_mean + 0.3) * delta * pow(alpha, beta - delta)
            loss *= beta / divisor

        return loss

    @classmethod
    def AIoU(cls, pred, target, anchors, psobj, self=None):
        self = self if self else cls(pred, target, anchors, psobj)
        dist = torch.exp(0.5 * (torch.square(self.d_center / self.wh_box.detach())).sum(dim=-1))
        return self._scaled_conf_loss(self._scaled_iou_loss(dist * self.iou))

    @classmethod
    def IoU(cls, pred, target, anchors, psobj, self=None):
        self = self if self else cls(pred, target, anchors, psobj)
        return self._scaled_conf_loss(self._scaled_iou_loss(self.iou))

    @classmethod
    def GIoU(cls, pred, target, anchors, psobj, self=None):
        self = self if self else cls(pred, target, anchors, psobj)
        return self._scaled_conf_loss(self._scaled_iou_loss(self.iou + (self.s_box - self.s_union) / self.s_box))

    @classmethod
    def DIoU(cls, pred, target, anchors, psobj, self=None):
        self = self if self else cls(pred, target, anchors, psobj)
        return self._scaled_conf_loss(self._scaled_iou_loss(self.iou + self.l2_center / self.l2_box.detach()))

    @classmethod
    def CIoU(cls, pred, target, anchors, psobj, eps=1e-4, self=None):
        self = self if self else cls(pred, target, anchors, psobj)
        v = 4 / math.pi ** 2 * \
            (torch.atan(self.pred_wh[..., 0] / (self.pred_wh[..., 1] + eps)) -
             torch.atan(self.target_wh[..., 0] / (self.target_wh[..., 1] + eps))) ** 2
        alpha = v / (self.iou + v)
        return self._scaled_conf_loss(
            self._scaled_iou_loss(self.iou + self.l2_center / self.l2_box + alpha.detach() * v))

    @classmethod
    def EIoU(cls, pred, target, anchors, psobj, self=None):
        self = self if self else cls(pred, target, anchors, psobj)
        dist = torch.exp(self.l2_center / self.l2_box.detach())
        rho = torch.square((self.pred_wh - self.target_wh) / self.wh_box.detach()).sum(dim=-1)
        return self._scaled_conf_loss(self._scaled_iou_loss(self.iou + dist + rho))

    @classmethod
    def SIoU(cls, pred, target, anchors, psobj, theta=4, self=None):
        self = self if self else cls(pred, target, anchors, psobj)
        # Angle Cost
        angle = torch.arcsin(torch.abs(self.d_center).min(dim=-1)[0] / (self.l2_center.sqrt() + 1e-4))
        angle = torch.sin(2 * angle) - 2
        # Dist Cost
        dist = angle[..., None] * torch.square(self.d_center / self.wh_box)
        dist = 2 - torch.exp(dist[..., 0]) - torch.exp(dist[..., 1])
        # Shape Cost
        d_shape = torch.abs(self.pred_wh - self.target_wh)
        big_shape = torch.maximum(self.pred_wh, self.target_wh)
        w_shape = 1 - torch.exp(- d_shape[..., 0] / big_shape[..., 0])
        h_shape = 1 - torch.exp(- d_shape[..., 1] / big_shape[..., 1])
        shape = w_shape ** theta + h_shape ** theta
        return self._scaled_conf_loss(self._scaled_iou_loss(self.iou + (dist + shape) / 2))

    @classmethod
    def WIoU(cls, pred, target, anchors, psobj, self=None):
        self = self if self else cls(pred, target, anchors, psobj)
        dist = torch.exp(self.l2_center / self.l2_box.detach())
        return self._scaled_conf_loss(self._scaled_iou_loss(dist * self.iou))
