import math
from typing import Tuple

from torch import Tensor
import torch


def box_area(boxes: Tensor) -> Tensor:
    """
    Computes the area of a set of bounding boxes, which are specified by its
    (x1, y1, x2, y2) coordinates.
    Arguments:
        boxes (Tensor[N, 4]): boxes for which the area will be computed. They
            are expected to be in (x1, y1, x2, y2) format
    Returns:
        area (Tensor[N]): area for each box
    """
    return (boxes[:, 2] - boxes[:, 0]) * (boxes[:, 3] - boxes[:, 1])


def box_iou(boxes1: Tensor, boxes2: Tensor) -> Tensor:
    """
    Return intersection-over-union (Jaccard index) of boxes.
    Both sets of boxes are expected to be in (x1, y1, x2, y2) format.
    Arguments:
        boxes1 (Tensor[N, 4])
        boxes2 (Tensor[M, 4])
    Returns:
        iou (Tensor[N, M]): the NxM matrix containing the pairwise IoU values for every element in boxes1 and boxes2
    """
    area1 = box_area(boxes1)  # (N,)
    area2 = box_area(boxes2)  # (M,)

    lt = torch.max(boxes1[:, None, :2], boxes2[:, :2])  # [N,M,2]
    rb = torch.min(boxes1[:, None, 2:], boxes2[:, 2:])  # [N,M,2]

    wh = (rb - lt).clamp(min=0)  # [N,M,2]
    inter = wh[:, :, 0] * wh[:, :, 1]  # [N,M]

    iou = inter / (area1[:, None] + area2 - inter)
    return iou  # NxM


def nms(boxes: Tensor, scores: Tensor, iou_threshold: float):
    """
    :param boxes: [N, 4]
    :param scores: [N]
    :param iou_threshold: 0.7
    :return:
    """
    keep = []  # The serial number of the reserved prediction box
    idxs = scores.argsort()  # Sort from highest to lowest based on confidence score
    while idxs.numel() > 0:
        # Number and border for maximum confidence
        max_score_index = idxs[-1]
        max_score_box = boxes[max_score_index][None, :]  # [1, 4]
        keep.append(max_score_index)
        if idxs.size(0) == 1:
            break
        idxs = idxs[:-1]  # Remove the bounding box with the highest confidence from the index
        other_boxes = boxes[idxs]  # [?, 4]
        ious = box_iou(max_score_box, other_boxes)  # Calculate IoU
        idxs = idxs[ious[0] <= iou_threshold]

    keep = idxs.new(keep)  # Tensor
    return keep


def nom_score(ious: Tensor, max_score: Tensor, other_score: Tensor, truncation_value: float = 0.3) -> Tensor:
    """
    Reweighting ious based on confidence
    Arguments:
        ious (Tensor[N, 1]): Ious will be reweighted.
        max_score (Tensor[1, 1]): The value of the maximum confidence.
        other_score (Tensor[N, 1]): The value of the non-maximum confidence.
        truncation_value (float) :
    Returns:
        Reweighting ious
    """
    if max_score < truncation_value:
        return ious
    scores_ratio = other_score / max_score
    # sco_penalty = -1 * torch.pow(w_weight, scores_ratio) + b_bias
    sco_penalty = 0.2*torch.cos((scores_ratio*math.pi)/2) + 1
    return ious * sco_penalty
    # return ious * (sco_penalty*0.5 + 0.5)


def boxes_fusion(ious, max_score_real_box, other_real_boxes, max_score, other_score, BF_thres=0.78):
    """
    Adjusting the bounding box for maximum confidence
    Arguments:
        ious (Tensor[N, 1]):
        max_score_real_box (Tensor[1, 1]): Unprocessed original bounding boxes of the maximum confidence.
        other_real_boxes (Tensor[N, 1]): Unprocessed original bounding boxes of the non-maximum confidence.
        max_score (Tensor[1, 1]): The value of the maximum confidence.
        other_score (Tensor[N, 1]): The value of the non-maximum confidence.
        BF_thres (float) :
    Returns:
        Bounding box after fusion
    """
    # v1
    # score_ratio = max_score / (max_score + other_score)
    # for idx_iou, i in enumerate(ious[0]):
    #     if i > BF_thres:
    #         adaptive_box = ((score_ratio[idx_iou] * max_score_real_box[0]) + ((1 - score_ratio[idx_iou]) * other_real_boxes[idx_iou])).reshape(1, 4)
    #         max_score_real_box = torch.cat((max_score_real_box, adaptive_box), dim=0)
    # if max_score_real_box.shape[0] == 1:
    #     return max_score_real_box
    # return torch.mean(max_score_real_box, dim=0)

    # v2
    score_ratio = (max_score / (max_score + other_score)).view(other_score.shape[0], 1).repeat(1, 4)
    is_gt = torch.gt(ious[0], BF_thres)
    is_gt_4d = is_gt.view(ious.shape[1], 1).repeat(1, 4)

    adaptive_box = is_gt_4d * ((score_ratio * max_score_real_box[0]) + ((1 - score_ratio) * other_real_boxes))
    max_score_adap_box = (adaptive_box.sum(dim=0)/is_gt.sum(dim=-1)).view(1, 4)

    return max_score_adap_box

def aiou_nms(boxes: Tensor, scores: Tensor, iou_threshold: float, real_boxes,
             aiou_nms=True, Pre_WBF=False, Sub_WBF=True):
    """
    :param boxes: [N, 4], Original bounding boxes
    :param scores: [N], Confidence score
    :param iou_threshold: 0.7
    :param real_boxes: [N, 4], Unprocessed original bounding boxes
    :return:
    """
    keep = []  # The serial number of the reserved prediction box
    idxs = scores.argsort()  # Sort from highest to lowest based on confidence score
    while idxs.numel() > 0:
        # Number and border for maximum confidence
        max_score_index = idxs[-1]
        max_score_box = boxes[max_score_index][None, :]  # [1, 4]
        max_score_real_box = real_boxes[max_score_index][None, :]  # [1, 4]
        max_score = scores[max_score_index]
        keep.append(max_score_index)
        if idxs.size(0) == 1:
            break

        idxs = idxs[:-1]  # Remove the bounding box with the highest confidence from the index
        other_boxes = boxes[idxs]  # [?, 4]
        other_real_boxes = real_boxes[idxs]  # [?, 4]
        other_score = scores[idxs]
        ious = box_iou(max_score_box, other_boxes)  # Calculate IoU

        if Pre_WBF:
            BF_boxes = boxes_fusion(ious, max_score_real_box, other_real_boxes, max_score, other_score, BF_thres=0.84)
            real_boxes[max_score_index][None, :] = BF_boxes
            max_score_real_box[0] = BF_boxes
            idxs = idxs[ious[0] <= 0.84]
            if idxs.size(0) < 2:
                break
            other_boxes = boxes[idxs]  # [?, 4]
            other_real_boxes = real_boxes[idxs]  # [?, 4]
            other_score = scores[idxs]
            ious = box_iou(max_score_box, other_boxes)  # 一个框和其余框比较 1XM
        # aiou-nms
        if aiou_nms:
            ious = nom_score(ious, max_score, other_score)

        if Sub_WBF:
            BF_boxes = boxes_fusion(ious, max_score_real_box, other_real_boxes, max_score, other_score)
            real_boxes[max_score_index][None, :] = BF_boxes
        idxs = idxs[ious[0] <= iou_threshold]
    keep = idxs.new(keep)  # Tensor
    return keep, real_boxes
