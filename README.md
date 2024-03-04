# AIoU loss

By [Yanchen Zhu](https://orcid.org/0000-0002-6123-6880),  [Wenhua Zheng](https://orcid.org/0009-0007-1002-809),  [Jianqiang Du](https://orcid.org/0000-0001-5584-9181), [Qiang Huang](https://orcid.org/0009-0002-8518-7769).

This repository is an official implementation of the paper [Autonomous-IOU Loss: Adaptive Dynamic Non-monotonic Focal IOU Loss](https://github.com/Wenhua-Zheng/AIOU).

## Comparative experiment

In order to fairly compare the performance of each loss function, we adopted the same training and validation environments. All training experiments were conducted on PyTorch framework. 16000 images from the MS-COCO 2017 dataset are used as the training set and 3000 images are used as the validation set with 80 classes.YOLOv7 is trained for 60 epochs with different BBR losses. [Click here to download comparative experimental data](https://github.com/Wenhua-Zheng/AIOU/releases)

| BBR loss    | AP           | AP50          | AP75         |
| ----------- | ------------ | ------------- | ------------ |
| IoU         | 42.29        | 61.02         | 45.03        |
| GIoU        | 42.55(+0.26) | 60.91(- 0.11) | 45.37(+0.34) |
| DIoU        | 42.49(+0.20) | 60.92(- 0.10) | 45.51(+0.48) |
| CIoU        | 42.44(+0.15) | 61.20(+0.18)  | 45.20(+0.17) |
| EIoU        | 42.46(+0.17) | 61.08(+0.06)  | 45.28(+0.25) |
| SIoU        | 42.42(+0.16) | 61.09(+0.07)  | 45.16(+0.13) |
| WIoU-v1     | 42.37(+0.08) | 61.18(+0.16)  | 45.12(+0.09) |
| WIoU-v2     | 42.45(+0.16) | 60.95(- 0.07) | 45.28(+0.25) |
| WIoU-v3     | 42.65(+0.36) | 61.51(+0.49)  | 45.66(+0.63) |
| AIoU-v1     | 42.44(+0.15) | 62.7(+1.68)   | 47.07(+2.07) |
| AIoU-v2     | 42.69(+0.40) | 61.13(+0.11)  | 45.55(+0.52) |
| AIoU-v3     | 42.90(+0.61) | 61.45(+0.43)  | 47.11(+2.08) |
| AIoU-v4     | 43.08(+0.79) | 61.44(+0.42)  | 46.11(+1.08) |
| AIoU-v4-NMS | 43.15(+0.86) | 61.48(+0.46)  | 46.19(+1.16) |

## Preparation work before training

Before training, we need to implant the IoU code into the YOLOv7. Make the following modifications to the project code of the model.

1. In ./utils/loss.py

   Annotate this piece of the original code and insert another piece of code:

``` shell
# # Intersection area
# inter = (torch.min(b1_x2, b2_x2) - torch.max(b1_x1, b2_x1)).clamp(0) * \
#         (torch.min(b1_y2, b2_y2) - torch.max(b1_y1, b2_y1)).clamp(0)
#
# # Union Area
# w1, h1 = b1_x2 - b1_x1, b1_y2 - b1_y1 + eps
# w2, h2 = b2_x2 - b2_x1, b2_y2 - b2_y1 + eps
# union = w1 * h1 + w2 * h2 - inter + eps
#
# iou = inter / union
#
# if GIoU or DIoU or CIoU:
#     cw = torch.max(b1_x2, b2_x2) - torch.min(b1_x1, b2_x1)  # convex (smallest enclosing box) width
#     ch = torch.max(b1_y2, b2_y2) - torch.min(b1_y1, b2_y1)  # convex height
#     if CIoU or DIoU:  # Distance or Complete IoU https://arxiv.org/abs/1911.08287v1
#         c2 = cw ** 2 + ch ** 2 + eps  # convex diagonal squared
#         rho2 = ((b2_x1 + b2_x2 - b1_x1 - b1_x2) ** 2 +
#                 (b2_y1 + b2_y2 - b1_y1 - b1_y2) ** 2) / 4  # center distance squared
#         if DIoU:
#             return iou - rho2 / c2  # DIoU
#         elif CIoU:  # https://github.com/Zzh-tju/DIoU-SSD-pytorch/blob/master/utils/box/box_utils.py#L47
#             v = (4 / math.pi ** 2) * torch.pow(torch.atan(w2 / (h2 + eps)) - torch.atan(w1 / (h1 + eps)), 2)
#             with torch.no_grad():
#                 alpha = v / (v - iou + (1 + eps))
#             return iou - (rho2 / c2 + v * alpha)  # CIoU
#     else:  # GIoU https://arxiv.org/pdf/1902.09630.pdf
#         c_area = cw * ch + eps  # convex area
#         return iou - (c_area - union) / c_area  # GIoU
# else:
#     return iou  # IoU

# ['based', 'monotonous', 'non_monotonous', 'adaptive']
self = IoU_Cal(b1, b2, anchors, psobj, iou_focal_loss='based', conf_focal_loss='based')
loss = getattr(IoU_Cal, type_)(b1, b2, anchors, psobj, self=self)
iou = 1 - self.iou

return loss, iou
```

2. In ./utils/general.py

   Annotate this piece of the original code and insert another piece of code:

``` shell
# iou = bbox_iou(pbox.T, tbox[i], x1y1x2y2=False, CIoU=True)

loss, iou = bbox_iou(pbox.T, tbox[i], anchors[i], psobj, x1y1x2y2=False, type_=self.iou_type)
```

3. Place iou.py under./utils

   Note: The code is derived from the modification of WIoU loss

## Preparation work for using AIoU-nms before testing

1. In ./utils/general.py

   Annotate this piece of the original code and insert another piece of code:

```
# i = torchvision.ops.nms(boxes, scores, iou_thres)  # NMS

i, real_boxes = aiou_nms(boxes, scores, iou_thres, x[:, :4])  # aiou_nms
x[:, :4] = real_boxes
```

2. Place AIoU_NMS.py under./utils