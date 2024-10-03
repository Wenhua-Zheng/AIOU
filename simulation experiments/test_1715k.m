% ---------------------------- to regresion -------------------------- % 
clear
clc
mm1=0;
is_regresion = 0;   % If not regression, use the previous results directly to draw a graph
if is_regresion==1
    fprintf('Processing regresion_process.m ...\n');
    F1=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\iou-1715k.txt','w');
    F2=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\giou-1715k.txt','w');
    F3=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\diou-1715k.txt','w');
    F4=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\ciou-1715k.txt','w');
    F5=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\eiou-1715k.txt','w');
    F6=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\diou_de-1715k.txt','w');
    F7=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\eiou_de-1715k.txt','w');
    F8=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\wiou-1715k.txt','w');
    F9=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\wiou_de-1715k.txt','w');

    % Write the losses during the training process in Excel, first write the header
    excle_iou = 'E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\iou-1715k.xls';
    count=zeros(200,1,'int32');
    for id=1:200
        count(id)=id;
    end
    xlswrite(excle_iou,{'name','iou','giou','diou','ciou','eiou','diou_de','aeiou','wiou','wiou_de'},'sheet1','A1:J1');
    xlswrite(excle_iou,count,'sheet1','A2:A201');

    rr=3*sqrt(rand(1,5000));
    seta=2*pi*rand(1,5000);
    xx=10+rr.*cos(seta);
    yy=10+rr.*sin(seta);
    c1=sqrt(3);
    c2=sqrt(2);

    i_x=zeros(200,1,'double');i_y=zeros(200,1,'double');i_w=zeros(200,1,'double');i_h=zeros(200,1,'double');
    g_x=zeros(200,1,'double');g_y=zeros(200,1,'double');g_w=zeros(200,1,'double');g_h=zeros(200,1,'double');
    d_x=zeros(200,1,'double');d_y=zeros(200,1,'double');d_w=zeros(200,1,'double');d_h=zeros(200,1,'double');
    c_x=zeros(200,1,'double');c_y=zeros(200,1,'double');c_w=zeros(200,1,'double');c_h=zeros(200,1,'double');
    e_x=zeros(200,1,'double');e_y=zeros(200,1,'double');e_w=zeros(200,1,'double');e_h=zeros(200,1,'double');
    d_de_x=zeros(200,1,'double');d_de_y=zeros(200,1,'double');d_de_w=zeros(200,1,'double');d_de_h=zeros(200,1,'double');
    e_de_x=zeros(200,1,'double');e_de_y=zeros(200,1,'double');e_de_w=zeros(200,1,'double');e_de_h=zeros(200,1,'double');
    w_x=zeros(200,1,'double');w_y=zeros(200,1,'double');w_w=zeros(200,1,'double');w_h=zeros(200,1,'double');
    w_de_x=zeros(200,1,'double');w_de_y=zeros(200,1,'double');w_de_w=zeros(200,1,'double');w_de_h=zeros(200,1,'double');

    position_x=zeros(1715000,1,'double');
    position_y=zeros(1715000,1,'double');
    position_w=zeros(1715000,1,'double');
    position_h=zeros(1715000,1,'double');


    IoU_Loss=zeros(1715000,1,'double');
    GIoU_Loss=zeros(1715000,1,'double');
    DIoU_Loss=zeros(1715000,1,'double');
    CIoU_Loss=zeros(1715000,1,'double');
    EIoU_Loss=zeros(1715000,1,'double');
    DIoU_de_Loss=zeros(1715000,1,'double');
    EIoU_de_Loss=zeros(1715000,1,'double');
    WIoU_Loss=zeros(1715000,1,'double');
    WIoU_de_Loss=zeros(1715000,1,'double');

    final_error_iou=zeros(1715000,1,'double');
    final_error_giou=zeros(1715000,1,'double');
    final_error_diou=zeros(1715000,1,'double');
    final_error_ciou=zeros(1715000,1,'double');
    final_error_eiou=zeros(1715000,1,'double');
    final_error_diou_de=zeros(1715000,1,'double');
    final_error_eiou_de=zeros(1715000,1,'double');
    final_error_wiou=zeros(1715000,1,'double');
    final_error_wiou_de=zeros(1715000,1,'double');
    % 5000 points
    for i=1:5000           
        fprintf('½ø¶È£º%.2f / 5000\n',i);
        pred_x=xx(i);
        pred_y=yy(i);
        for c=1:7
            if c==1
                gt_w=0.5;
                gt_h=2.0;
            end
            if c==2
                gt_w=c1/3;
                gt_h=c1;
            end
            if c==3
                gt_w=c2/2;
                gt_h=c2;
            end
            if c==4
                gt_w=1;
                gt_h=1;
            end
            if c==5
                gt_w=c2;
                gt_h=c2/2;
            end
            if c==6
                gt_w=c1;
                gt_h=c1/3;
            end
            if c==7
                gt_w=2.0;
                gt_h=0.5;
            end
            gt=[10,10,gt_w,gt_h];       %7 aspect ratios of target boxes

            for o=1:7
                if o==1
                    S=0.5*gt_w*gt_h;
                end
                if o==2
                    S=0.67*gt_w*gt_h;
                end
                if o==3
                    S=0.75*gt_w*gt_h;
                end
                if o==4
                    S=1*gt_w*gt_h;
                end
                if o==5
                    S=1.33*gt_w*gt_h;
                end
                if o==6
                    S=1.5*gt_w*gt_h;
                end
                if o==7
                    S=2.0*gt_w*gt_h;                %7 scales of anchor boxes
                end


                iou0=zeros(7,1,'double');
                giou0=zeros(7,1,'double');
                diou0=zeros(7,1,'double');
                ciou0=zeros(7,1,'double');
                eiou0=zeros(7,1,'double');
                diou_de0=zeros(7,1,'double');
                eiou_de0=zeros(7,1,'double');
                wiou0=zeros(7,1,'double');
                wiou_de0=zeros(7,1,'double');

                for l=1:7
                    if l==1
                        pred_w=0.5*sqrt(S);
                        pred_h=2.0*sqrt(S);
                    end
                    if l==2
                        pred_w=c1/3*sqrt(S);
                        pred_h=c1*sqrt(S);
                    end
                    if l==3
                        pred_w=c2/2*sqrt(S);
                        pred_h=c2*sqrt(S);
                    end
                    if l==4
                        pred_w=1.0*sqrt(S);
                        pred_h=1.0*sqrt(S);
                    end
                    if l==5
                        pred_w=c2*sqrt(S);
                        pred_h=c2/2*sqrt(S);
                    end
                    if l==6
                        pred_w=c1*sqrt(S);
                        pred_h=c1/3*sqrt(S);
                    end
                    if l==7
                        pred_w=2.0*sqrt(S);
                        pred_h=0.5*sqrt(S);
                    end
                    pred=[pred_x,pred_y,pred_w,pred_h];       %7 aspect ratios of anchor boxes

                    mm1=mm1+1;
                    position_x(mm1)=pred_x;
                    position_y(mm1)=pred_y;
                    position_w(mm1)=pred_w;
                    position_h(mm1)=pred_h;
                    
                    % IoU
                    pred1=pred;
                    epoch_id=zeros(200,4,'double');
                    loss1=zeros(1,4,'double');
                    for k=1:160					%do bounding box regression by gradient descent algorithm
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred1);
                        IO=iou(pred_tblr,gt_tblr);
                        diou=dIOU(pred_tblr,gt_tblr);
                        diou_xywh=to_xywh(diou);
                        pred1(1)=pred1(1)+0.1*(2-IO)*diou_xywh.dx;
                        pred1(2)=pred1(2)+0.1*(2-IO)*diou_xywh.dy;
                        pred1(3)=pred1(3)+0.1*(2-IO)*diou_xywh.dw;
                        pred1(4)=pred1(4)+0.1*(2-IO)*diou_xywh.dh;
                        epoch_id(k,2:5)=pred1;
                        loss1=abs(epoch_id(k,2:5)-gt(1:4))+loss1;
                        i_x(k)=abs(pred1(1)-gt(1))+i_x(k);
                        i_y(k)=abs(pred1(2)-gt(2))+i_y(k);
                        i_w(k)=abs(pred1(3)-gt(3))+i_w(k);
                        i_h(k)=abs(pred1(4)-gt(4))+i_h(k);
                    end
                    for k=161:180
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred1);
                        IO=iou(pred_tblr,gt_tblr);
                        diou=dIOU(pred_tblr,gt_tblr);
                        diou_xywh=to_xywh(diou);
                        pred1(1)=pred1(1)+0.01*(2-IO)*diou_xywh.dx;
                        pred1(2)=pred1(2)+0.01*(2-IO)*diou_xywh.dy;
                        pred1(3)=pred1(3)+0.01*(2-IO)*diou_xywh.dw;
                        pred1(4)=pred1(4)+0.01*(2-IO)*diou_xywh.dh;
                        epoch_id(k,2:5)=pred1;
                        loss1=abs(epoch_id(k,2:5)-gt(1:4))+loss1;
                        i_x(k)=abs(pred1(1)-gt(1))+i_x(k);
                        i_y(k)=abs(pred1(2)-gt(2))+i_y(k);
                        i_w(k)=abs(pred1(3)-gt(3))+i_w(k);
                        i_h(k)=abs(pred1(4)-gt(4))+i_h(k);
                    end
                    for k=181:200
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred1);
                        IO=iou(pred_tblr,gt_tblr);
                        diou=dIOU(pred_tblr,gt_tblr);
                        diou_xywh=to_xywh(diou);
                        pred1(1)=pred1(1)+0.001*(2-IO)*diou_xywh.dx;
                        pred1(2)=pred1(2)+0.001*(2-IO)*diou_xywh.dy;
                        pred1(3)=pred1(3)+0.001*(2-IO)*diou_xywh.dw;
                        pred1(4)=pred1(4)+0.001*(2-IO)*diou_xywh.dh;
                        epoch_id(k,2:5)=pred1;
                        loss1=abs(epoch_id(k,2:5)-gt(1:4))+loss1;
                        i_x(k)=abs(pred1(1)-gt(1))+i_x(k);
                        i_y(k)=abs(pred1(2)-gt(2))+i_y(k);
                        i_w(k)=abs(pred1(3)-gt(3))+i_w(k);
                        i_h(k)=abs(pred1(4)-gt(4))+i_h(k);
                    end
                    final_error_iou(mm1)=abs(pred1(1)-gt(1))+abs(pred1(2)-gt(2))+abs(pred1(3)-gt(3))+abs(pred1(4)-gt(4));
                    iou0(l)=loss1(1)+loss1(2)+loss1(3)+loss1(4);
                    IoU_Loss(mm1)=iou0(l);
                    fprintf(F1, '%d\t',mm1);
                    fprintf(F1, '%f\t',position_x(mm1));
                    fprintf(F1, '%f\t',position_y(mm1));
                    fprintf(F1, '%f\t',position_w(mm1));
                    fprintf(F1, '%f\t',position_h(mm1));
                    fprintf(F1, '%f\t',IoU_Loss(mm1));
                    fprintf(F1, '%f\n',final_error_iou(mm1));				%save results for every regression cases

                    % GIoU
                    pred2=pred;
                    epoch_id=zeros(200,4,'double');
                    loss2=zeros(1,4,'double');
                    for k=1:160                                             %do bounding box regression by gradient descent algorithm
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred2);
                        IO=iou(pred_tblr,gt_tblr);
                        dgiou=dGIOU(pred_tblr,gt_tblr);
                        dgiou_xywh=to_xywh(dgiou);
                        pred2(1)=pred2(1)+0.1*(2-IO)*dgiou_xywh.dx;
                        pred2(2)=pred2(2)+0.1*(2-IO)*dgiou_xywh.dy;
                        pred2(3)=pred2(3)+0.1*(2-IO)*dgiou_xywh.dw;
                        pred2(4)=pred2(4)+0.1*(2-IO)*dgiou_xywh.dh;
                        epoch_id(k,2:5)=pred2;
                        loss2=abs(epoch_id(k,2:5)-gt(1:4))+loss2;
                        g_x(k)=abs(pred2(1)-gt(1))+g_x(k);
                        g_y(k)=abs(pred2(2)-gt(2))+g_y(k);
                        g_w(k)=abs(pred2(3)-gt(3))+g_w(k);
                        g_h(k)=abs(pred2(4)-gt(4))+g_h(k);
                    end
                    for k=161:180
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred2);
                        IO=iou(pred_tblr,gt_tblr);
                        dgiou=dGIOU(pred_tblr,gt_tblr);
                        dgiou_xywh=to_xywh(dgiou);
                        pred2(1)=pred2(1)+0.01*(2-IO)*dgiou_xywh.dx;
                        pred2(2)=pred2(2)+0.01*(2-IO)*dgiou_xywh.dy;
                        pred2(3)=pred2(3)+0.01*(2-IO)*dgiou_xywh.dw;
                        pred2(4)=pred2(4)+0.01*(2-IO)*dgiou_xywh.dh;
                        epoch_id(k,2:5)=pred2;
                        loss2=abs(epoch_id(k,2:5)-gt(1:4))+loss2;
                        g_x(k)=abs(pred2(1)-gt(1))+g_x(k);
                        g_y(k)=abs(pred2(2)-gt(2))+g_y(k);
                        g_w(k)=abs(pred2(3)-gt(3))+g_w(k);
                        g_h(k)=abs(pred2(4)-gt(4))+g_h(k);
                    end
                    for k=181:200
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred2);
                        IO=iou(pred_tblr,gt_tblr);
                        dgiou=dGIOU(pred_tblr,gt_tblr);
                        dgiou_xywh=to_xywh(dgiou);
                        pred2(1)=pred2(1)+0.001*(2-IO)*dgiou_xywh.dx;
                        pred2(2)=pred2(2)+0.001*(2-IO)*dgiou_xywh.dy;
                        pred2(3)=pred2(3)+0.001*(2-IO)*dgiou_xywh.dw;
                        pred2(4)=pred2(4)+0.001*(2-IO)*dgiou_xywh.dh;
                        epoch_id(k,2:5)=pred2;
                        loss2=abs(epoch_id(k,2:5)-gt(1:4))+loss2;
                        g_x(k)=abs(pred2(1)-gt(1))+g_x(k);
                        g_y(k)=abs(pred2(2)-gt(2))+g_y(k);
                        g_w(k)=abs(pred2(3)-gt(3))+g_w(k);
                        g_h(k)=abs(pred2(4)-gt(4))+g_h(k);
                    end
                    final_error_giou(mm1)=abs(pred2(1)-gt(1))+abs(pred2(2)-gt(2))+abs(pred2(3)-gt(3))+abs(pred2(4)-gt(4));
                    giou0(l)=loss2(1)+loss2(2)+loss2(3)+loss2(4);
                    GIoU_Loss(mm1)=giou0(l);
                    fprintf(F2, '%d\t',mm1);
                    fprintf(F2, '%f\t',position_x(mm1));
                    fprintf(F2, '%f\t',position_y(mm1));
                    fprintf(F2, '%f\t',position_w(mm1));
                    fprintf(F2, '%f\t',position_h(mm1));
                    fprintf(F2, '%f\t',GIoU_Loss(mm1));
                    fprintf(F2, '%f\n',final_error_giou(mm1));				%save results for every regression cases

                    pred3=pred;
                    epoch_id=zeros(200,4,'double');
                    loss3=zeros(1,4,'double');
                    for k=1:160
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred3);
                        IO=iou(pred_tblr,gt_tblr);
                        ddiou=dDIOU(pred3,gt);
                        pred3(1)=pred3(1)+0.1*(2-IO)*ddiou.dx;
                        pred3(2)=pred3(2)+0.1*(2-IO)*ddiou.dy;
                        pred3(3)=pred3(3)+0.1*(2-IO)*ddiou.dw;
                        pred3(4)=pred3(4)+0.1*(2-IO)*ddiou.dh;
                        epoch_id(k,2:5)=pred3;
                        loss3=abs(epoch_id(k,2:5)-gt(1:4))+loss3;
                        d_x(k)=abs(pred3(1)-gt(1))+d_x(k);
                        d_y(k)=abs(pred3(2)-gt(2))+d_y(k);
                        d_w(k)=abs(pred3(3)-gt(3))+d_w(k);
                        d_h(k)=abs(pred3(4)-gt(4))+d_h(k);
                    end
                    for k=161:180
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred3);
                        IO=iou(pred_tblr,gt_tblr);
                        ddiou=dDIOU(pred3,gt);
                        pred3(1)=pred3(1)+0.01*(2-IO)*ddiou.dx;
                        pred3(2)=pred3(2)+0.01*(2-IO)*ddiou.dy;
                        pred3(3)=pred3(3)+0.01*(2-IO)*ddiou.dw;
                        pred3(4)=pred3(4)+0.01*(2-IO)*ddiou.dh;
                        epoch_id(k,2:5)=pred3;
                        loss3=abs(epoch_id(k,2:5)-gt(1:4))+loss3;
                        d_x(k)=abs(pred3(1)-gt(1))+d_x(k);
                        d_y(k)=abs(pred3(2)-gt(2))+d_y(k);
                        d_w(k)=abs(pred3(3)-gt(3))+d_w(k);
                        d_h(k)=abs(pred3(4)-gt(4))+d_h(k);
                    end
                    for k=181:200
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred3);
                        IO=iou(pred_tblr,gt_tblr);
                        ddiou=dDIOU(pred3,gt);
                        pred3(1)=pred3(1)+0.001*(2-IO)*ddiou.dx;
                        pred3(2)=pred3(2)+0.001*(2-IO)*ddiou.dy;
                        pred3(3)=pred3(3)+0.001*(2-IO)*ddiou.dw;
                        pred3(4)=pred3(4)+0.001*(2-IO)*ddiou.dh;
                        epoch_id(k,2:5)=pred3;
                        loss3=abs(epoch_id(k,2:5)-gt(1:4))+loss3;
                        d_x(k)=abs(pred3(1)-gt(1))+d_x(k);
                        d_y(k)=abs(pred3(2)-gt(2))+d_y(k);
                        d_w(k)=abs(pred3(3)-gt(3))+d_w(k);
                        d_h(k)=abs(pred3(4)-gt(4))+d_h(k);
                    end
                    final_error_diou(mm1)=abs(pred3(1)-gt(1))+abs(pred3(2)-gt(2))+abs(pred3(3)-gt(3))+abs(pred3(4)-gt(4));
                    diou0(l)=loss3(1)+loss3(2)+loss3(3)+loss3(4);
                    DIoU_Loss(mm1)=diou0(l);
                    fprintf(F3, '%d\t',mm1);
                    fprintf(F3, '%f\t',position_x(mm1));
                    fprintf(F3, '%f\t',position_y(mm1));
                    fprintf(F3, '%f\t',position_w(mm1));
                    fprintf(F3, '%f\t',position_h(mm1));
                    fprintf(F3, '%f\t',DIoU_Loss(mm1));
                    fprintf(F3, '%f\n',final_error_diou(mm1));				%save results for every regression cases

                    % CIoU
                    pred4=pred;
                    epoch_id=zeros(200,4,'double');
                    loss4=zeros(1,4,'double');
                    for k=1:160
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred4);
                        IO=iou(pred_tblr,gt_tblr);
                        dciou=dCIOU(pred4,gt);
                        pred4(1)=pred4(1)+0.1*(2-IO)*dciou.dx;
                        pred4(2)=pred4(2)+0.1*(2-IO)*dciou.dy;
                        pred4(3)=pred4(3)+0.1*(2-IO)*dciou.dw;
                        pred4(4)=pred4(4)+0.1*(2-IO)*dciou.dh;
                        epoch_id(k,2:5)=pred4;
                        loss4=abs(epoch_id(k,2:5)-gt(1:4))+loss4;
                        c_x(k)=abs(pred4(1)-gt(1))+c_x(k);
                        c_y(k)=abs(pred4(2)-gt(2))+c_y(k);
                        c_w(k)=abs(pred4(3)-gt(3))+c_w(k);
                        c_h(k)=abs(pred4(4)-gt(4))+c_h(k);
                    end
                    for k=161:180
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred4);
                        IO=iou(pred_tblr,gt_tblr);
                        dciou=dCIOU(pred4,gt);
                        pred4(1)=pred4(1)+0.01*(2-IO)*dciou.dx;
                        pred4(2)=pred4(2)+0.01*(2-IO)*dciou.dy;
                        pred4(3)=pred4(3)+0.01*(2-IO)*dciou.dw;
                        pred4(4)=pred4(4)+0.01*(2-IO)*dciou.dh;
                        epoch_id(k,2:5)=pred4;
                        loss4=abs(epoch_id(k,2:5)-gt(1:4))+loss4;
                        c_x(k)=abs(pred4(1)-gt(1))+c_x(k);
                        c_y(k)=abs(pred4(2)-gt(2))+c_y(k);
                        c_w(k)=abs(pred4(3)-gt(3))+c_w(k);
                        c_h(k)=abs(pred4(4)-gt(4))+c_h(k);
                    end
                    for k=181:200
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred4);
                        IO=iou(pred_tblr,gt_tblr);
                        dciou=dCIOU(pred4,gt);
                        pred4(1)=pred4(1)+0.001*(2-IO)*dciou.dx;
                        pred4(2)=pred4(2)+0.001*(2-IO)*dciou.dy;
                        pred4(3)=pred4(3)+0.001*(2-IO)*dciou.dw;
                        pred4(4)=pred4(4)+0.001*(2-IO)*dciou.dh;
                        epoch_id(k,2:5)=pred4;
                        loss4=abs(epoch_id(k,2:5)-gt(1:4))+loss4;
                        c_x(k)=abs(pred4(1)-gt(1))+c_x(k);
                        c_y(k)=abs(pred4(2)-gt(2))+c_y(k);
                        c_w(k)=abs(pred4(3)-gt(3))+c_w(k);
                        c_h(k)=abs(pred4(4)-gt(4))+c_h(k);
                    end
                    final_error_ciou(mm1)=abs(pred4(1)-gt(1))+abs(pred4(2)-gt(2))+abs(pred4(3)-gt(3))+abs(pred4(4)-gt(4));
                    ciou0(l)=loss4(1)+loss4(2)+loss4(3)+loss4(4);
                    CIoU_Loss(mm1)=ciou0(l);
                    fprintf(F4, '%d\t',mm1);
                    fprintf(F4, '%f\t',position_x(mm1));
                    fprintf(F4, '%f\t',position_y(mm1));
                    fprintf(F4, '%f\t',position_w(mm1));
                    fprintf(F4, '%f\t',position_h(mm1));
                    fprintf(F4, '%f\t',CIoU_Loss(mm1));
                    fprintf(F4, '%f\n',final_error_ciou(mm1));				%save results for every regression cases

                    % EIOU
                    pred5=pred;
                    epoch_id=zeros(200,4,'double');
                    loss5=zeros(1,4,'double');
                    for k=1:160
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred5);
                        IO=iou(pred_tblr,gt_tblr);
                        deiou=dEIOU(pred5,gt);
                        pred5(1)=pred5(1)+0.1*(2-IO)*deiou.dx;
                        pred5(2)=pred5(2)+0.1*(2-IO)*deiou.dy;
                        pred5(3)=pred5(3)+0.1*(2-IO)*deiou.dw;
                        pred5(4)=pred5(4)+0.1*(2-IO)*deiou.dh;
                        epoch_id(k,2:5)=pred5;
                        loss5=abs(epoch_id(k,2:5)-gt(1:4))+loss5;
                        e_x(k)=abs(pred5(1)-gt(1))+e_x(k);
                        e_y(k)=abs(pred5(2)-gt(2))+e_y(k);
                        e_w(k)=abs(pred5(3)-gt(3))+e_w(k);
                        e_h(k)=abs(pred5(4)-gt(4))+e_h(k);
                    end
                    for k=161:180
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred5);
                        IO=iou(pred_tblr,gt_tblr);
                        deiou=dEIOU(pred5,gt);
                        pred5(1)=pred5(1)+0.01*(2-IO)*deiou.dx;
                        pred5(2)=pred5(2)+0.01*(2-IO)*deiou.dy;
                        pred5(3)=pred5(3)+0.01*(2-IO)*deiou.dw;
                        pred5(4)=pred5(4)+0.01*(2-IO)*deiou.dh;
                        epoch_id(k,2:5)=pred5;
                        loss5=abs(epoch_id(k,2:5)-gt(1:4))+loss5;
                        e_x(k)=abs(pred5(1)-gt(1))+e_x(k);
                        e_y(k)=abs(pred5(2)-gt(2))+e_y(k);
                        e_w(k)=abs(pred5(3)-gt(3))+e_w(k);
                        e_h(k)=abs(pred5(4)-gt(4))+e_h(k);
                    end
                    for k=181:200
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred5);
                        IO=iou(pred_tblr,gt_tblr);
                        deiou=dEIOU(pred5,gt);
                        pred5(1)=pred5(1)+0.001*(2-IO)*deiou.dx;
                        pred5(2)=pred5(2)+0.001*(2-IO)*deiou.dy;
                        pred5(3)=pred5(3)+0.001*(2-IO)*deiou.dw;
                        pred5(4)=pred5(4)+0.001*(2-IO)*deiou.dh;
                        epoch_id(k,2:5)=pred5;
                        loss5=abs(epoch_id(k,2:5)-gt(1:4))+loss5;
                        e_x(k)=abs(pred5(1)-gt(1))+e_x(k);
                        e_y(k)=abs(pred5(2)-gt(2))+e_y(k);
                        e_w(k)=abs(pred5(3)-gt(3))+e_w(k);
                        e_h(k)=abs(pred5(4)-gt(4))+e_h(k);
                    end
                    final_error_diou_de(mm1)=abs(pred5(1)-gt(1))+abs(pred5(2)-gt(2))+abs(pred5(3)-gt(3))+abs(pred5(4)-gt(4));
                    eiou0(l)=loss5(1)+loss5(2)+loss5(3)+loss5(4);
                    EIoU_Loss(mm1)=eiou0(l);
                    fprintf(F5, '%d\t',mm1);
                    fprintf(F5, '%f\t',position_x(mm1));
                    fprintf(F5, '%f\t',position_y(mm1));
                    fprintf(F5, '%f\t',position_w(mm1));
                    fprintf(F5, '%f\t',position_h(mm1));
                    fprintf(F5, '%f\t',EIoU_Loss(mm1));
                    fprintf(F5, '%f\n',final_error_diou_de(mm1));				%save results for every regression cases

                    % DIOU_de
                    pred6=pred;
                    epoch_id=zeros(200,4,'double');
                    loss6=zeros(1,4,'double');
                    for k=1:160
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred6);
                        IO=iou(pred_tblr,gt_tblr);
                        ddiou_de=dDIOU_de(pred6,gt);
                        pred6(1)=pred6(1)+0.1*(2-IO)*ddiou_de.dx;
                        pred6(2)=pred6(2)+0.1*(2-IO)*ddiou_de.dy;
                        pred6(3)=pred6(3)+0.1*(2-IO)*ddiou_de.dw;
                        pred6(4)=pred6(4)+0.1*(2-IO)*ddiou_de.dh;
                        epoch_id(k,2:5)=pred6;
                        loss6=abs(epoch_id(k,2:5)-gt(1:4))+loss6;
                        d_de_x(k)=abs(pred6(1)-gt(1))+d_de_x(k);
                        d_de_y(k)=abs(pred6(2)-gt(2))+d_de_y(k);
                        d_de_w(k)=abs(pred6(3)-gt(3))+d_de_w(k);
                        d_de_h(k)=abs(pred6(4)-gt(4))+d_de_h(k);
                    end
                    for k=161:180
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred6);
                        IO=iou(pred_tblr,gt_tblr);
                        ddiou_de=dDIOU_de(pred6,gt);
                        pred6(1)=pred6(1)+0.01*(2-IO)*ddiou_de.dx;
                        pred6(2)=pred6(2)+0.01*(2-IO)*ddiou_de.dy;
                        pred6(3)=pred6(3)+0.01*(2-IO)*ddiou_de.dw;
                        pred6(4)=pred6(4)+0.01*(2-IO)*ddiou_de.dh;
                        epoch_id(k,2:5)=pred6;
                        loss6=abs(epoch_id(k,2:5)-gt(1:4))+loss6;
                        d_de_x(k)=abs(pred6(1)-gt(1))+d_de_x(k);
                        d_de_y(k)=abs(pred6(2)-gt(2))+d_de_y(k);
                        d_de_w(k)=abs(pred6(3)-gt(3))+d_de_w(k);
                        d_de_h(k)=abs(pred6(4)-gt(4))+d_de_h(k);
                    end
                    for k=181:200
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred6);
                        IO=iou(pred_tblr,gt_tblr);
                        ddiou_de=dDIOU_de(pred6,gt);
                        pred6(1)=pred6(1)+0.001*(2-IO)*ddiou_de.dx;
                        pred6(2)=pred6(2)+0.001*(2-IO)*ddiou_de.dy;
                        pred6(3)=pred6(3)+0.001*(2-IO)*ddiou_de.dw;
                        pred6(4)=pred6(4)+0.001*(2-IO)*ddiou_de.dh;
                        epoch_id(k,2:5)=pred6;
                        loss6=abs(epoch_id(k,2:5)-gt(1:4))+loss6;
                        d_de_x(k)=abs(pred6(1)-gt(1))+d_de_x(k);
                        d_de_y(k)=abs(pred6(2)-gt(2))+d_de_y(k);
                        d_de_w(k)=abs(pred6(3)-gt(3))+d_de_w(k);
                        d_de_h(k)=abs(pred6(4)-gt(4))+d_de_h(k);
                    end
                    final_error_diou_de(mm1)=abs(pred6(1)-gt(1))+abs(pred6(2)-gt(2))+abs(pred6(3)-gt(3))+abs(pred6(4)-gt(4));
                    diou_de0(l)=loss6(1)+loss6(2)+loss6(3)+loss6(4);
                    DIoU_de_Loss(mm1)=diou_de0(l);
                    fprintf(F6, '%d\t',mm1);
                    fprintf(F6, '%f\t',position_x(mm1));
                    fprintf(F6, '%f\t',position_y(mm1));
                    fprintf(F6, '%f\t',position_w(mm1));
                    fprintf(F6, '%f\t',position_h(mm1));
                    fprintf(F6, '%f\t',DIoU_de_Loss(mm1));
                    fprintf(F6, '%f\n',final_error_diou_de(mm1));				%save results for every regression cases

                    % EIOU_de
                    pred7=pred;
                    epoch_id=zeros(200,4,'double');
                    loss7=zeros(1,4,'double');
                    for k=1:160
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred7);
                        IO=iou(pred_tblr,gt_tblr);
                        deiou_de=dEIOU_de(pred7,gt);
                        pred7(1)=pred7(1)+0.1*(2-IO)*deiou_de.dx;
                        pred7(2)=pred7(2)+0.1*(2-IO)*deiou_de.dy;
                        pred7(3)=pred7(3)+0.1*(2-IO)*deiou_de.dw;
                        pred7(4)=pred7(4)+0.1*(2-IO)*deiou_de.dh;
                        epoch_id(k,2:5)=pred7;
                        loss7=abs(epoch_id(k,2:5)-gt(1:4))+loss7;
                        e_de_x(k)=abs(pred7(1)-gt(1))+e_de_x(k);
                        e_de_y(k)=abs(pred7(2)-gt(2))+e_de_y(k);
                        e_de_w(k)=abs(pred7(3)-gt(3))+e_de_w(k);
                        e_de_h(k)=abs(pred7(4)-gt(4))+e_de_h(k);
                    end
                    for k=161:180
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred7);
                        IO=iou(pred_tblr,gt_tblr);
                        deiou_de=dEIOU_de(pred7,gt);
                        pred7(1)=pred7(1)+0.01*(2-IO)*deiou_de.dx;
                        pred7(2)=pred7(2)+0.01*(2-IO)*deiou_de.dy;
                        pred7(3)=pred7(3)+0.01*(2-IO)*deiou_de.dw;
                        pred7(4)=pred7(4)+0.01*(2-IO)*deiou_de.dh;
                        epoch_id(k,2:5)=pred7;
                        loss7=abs(epoch_id(k,2:5)-gt(1:4))+loss7;
                        e_de_x(k)=abs(pred7(1)-gt(1))+e_de_x(k);
                        e_de_y(k)=abs(pred7(2)-gt(2))+e_de_y(k);
                        e_de_w(k)=abs(pred7(3)-gt(3))+e_de_w(k);
                        e_de_h(k)=abs(pred7(4)-gt(4))+e_de_h(k);
                    end
                    for k=181:200
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred7);
                        IO=iou(pred_tblr,gt_tblr);
                        deiou_de=dEIOU_de(pred7,gt);
                        pred7(1)=pred7(1)+0.001*(2-IO)*deiou_de.dx;
                        pred7(2)=pred7(2)+0.001*(2-IO)*deiou_de.dy;
                        pred7(3)=pred7(3)+0.001*(2-IO)*deiou_de.dw;
                        pred7(4)=pred7(4)+0.001*(2-IO)*deiou_de.dh;
                        epoch_id(k,2:5)=pred7;
                        loss7=abs(epoch_id(k,2:5)-gt(1:4))+loss7;
                        e_de_x(k)=abs(pred7(1)-gt(1))+e_de_x(k);
                        e_de_y(k)=abs(pred7(2)-gt(2))+e_de_y(k);
                        e_de_w(k)=abs(pred7(3)-gt(3))+e_de_w(k);
                        e_de_h(k)=abs(pred7(4)-gt(4))+e_de_h(k);
                    end
                    final_error_eiou_de(mm1)=abs(pred7(1)-gt(1))+abs(pred7(2)-gt(2))+abs(pred7(3)-gt(3))+abs(pred7(4)-gt(4));
                    eiou_de0(l)=loss7(1)+loss7(2)+loss7(3)+loss7(4);
                    EIoU_de_Loss(mm1)=eiou_de0(l);
                    fprintf(F7, '%d\t',mm1);
                    fprintf(F7, '%f\t',position_x(mm1));
                    fprintf(F7, '%f\t',position_y(mm1));
                    fprintf(F7, '%f\t',position_w(mm1));
                    fprintf(F7, '%f\t',position_h(mm1));
                    fprintf(F7, '%f\t',EIoU_de_Loss(mm1));
                    fprintf(F7, '%f\n',final_error_eiou_de(mm1));				%save results for every regression cases
                    
                    % WIOU
                    pred8=pred;
                    epoch_id=zeros(200,4,'double');
                    loss8=zeros(1,4,'double');
                    for k=1:160
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred8);
                        IO=iou(pred_tblr,gt_tblr);
                        dwiou=dWIOU(pred8,gt);
                        pred8(1)=pred8(1)+0.1*(2-IO)*dwiou.dx;
                        pred8(2)=pred8(2)+0.1*(2-IO)*dwiou.dy;
                        pred8(3)=pred8(3)+0.1*(2-IO)*dwiou.dw;
                        pred8(4)=pred8(4)+0.1*(2-IO)*dwiou.dh;
                        epoch_id(k,2:5)=pred8;
                        loss8=abs(epoch_id(k,2:5)-gt(1:4))+loss8;
                        w_x(k)=abs(pred8(1)-gt(1))+w_x(k);
                        w_y(k)=abs(pred8(2)-gt(2))+w_y(k);
                        w_w(k)=abs(pred8(3)-gt(3))+w_w(k);
                        w_h(k)=abs(pred8(4)-gt(4))+w_h(k);
                    end
                    for k=161:180
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred8);
                        IO=iou(pred_tblr,gt_tblr);
                        dwiou=dWIOU(pred8,gt);
                        pred8(1)=pred8(1)+0.01*(2-IO)*dwiou.dx;
                        pred8(2)=pred8(2)+0.01*(2-IO)*dwiou.dy;
                        pred8(3)=pred8(3)+0.01*(2-IO)*dwiou.dw;
                        pred8(4)=pred8(4)+0.01*(2-IO)*dwiou.dh;
                        epoch_id(k,2:5)=pred8;
                        loss8=abs(epoch_id(k,2:5)-gt(1:4))+loss8;
                        w_x(k)=abs(pred8(1)-gt(1))+w_x(k);
                        w_y(k)=abs(pred8(2)-gt(2))+w_y(k);
                        w_w(k)=abs(pred8(3)-gt(3))+w_w(k);
                        w_h(k)=abs(pred8(4)-gt(4))+w_h(k);
                    end
                    for k=181:200
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred8);
                        IO=iou(pred_tblr,gt_tblr);
                        dwiou=dWIOU(pred8,gt);
                        pred8(1)=pred8(1)+0.001*(2-IO)*dwiou.dx;
                        pred8(2)=pred8(2)+0.001*(2-IO)*dwiou.dy;
                        pred8(3)=pred8(3)+0.001*(2-IO)*dwiou.dw;
                        pred8(4)=pred8(4)+0.001*(2-IO)*dwiou.dh;
                        epoch_id(k,2:5)=pred8;
                        loss8=abs(epoch_id(k,2:5)-gt(1:4))+loss8;
                        w_x(k)=abs(pred8(1)-gt(1))+w_x(k);
                        w_y(k)=abs(pred8(2)-gt(2))+w_y(k);
                        w_w(k)=abs(pred8(3)-gt(3))+w_w(k);
                        w_h(k)=abs(pred8(4)-gt(4))+w_h(k);
                    end
                    final_error_wiou(mm1)=abs(pred8(1)-gt(1))+abs(pred8(2)-gt(2))+abs(pred8(3)-gt(3))+abs(pred8(4)-gt(4));
                    wiou0(l)=loss8(1)+loss8(2)+loss8(3)+loss8(4);
                    WIoU_Loss(mm1)=wiou0(l);
                    fprintf(F8, '%d\t',mm1);
                    fprintf(F8, '%f\t',position_x(mm1));
                    fprintf(F8, '%f\t',position_y(mm1));
                    fprintf(F8, '%f\t',position_w(mm1));
                    fprintf(F8, '%f\t',position_h(mm1));
                    fprintf(F8, '%f\t',WIoU_Loss(mm1));
                    fprintf(F8, '%f\n',final_error_wiou(mm1));				%save results for every regression cases
                    
                    %WIOU_de
                    pred9=pred;
                    epoch_id=zeros(200,4,'double');
                    loss9=zeros(1,4,'double');
                    for k=1:160
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred9);
                        IO=iou(pred_tblr,gt_tblr);
                        dwiou_de=dWIOU_de(pred9,gt);
                        pred9(1)=pred9(1)+0.1*(2-IO)*dwiou_de.dx;
                        pred9(2)=pred9(2)+0.1*(2-IO)*dwiou_de.dy;
                        pred9(3)=pred9(3)+0.1*(2-IO)*dwiou_de.dw;
                        pred9(4)=pred9(4)+0.1*(2-IO)*dwiou_de.dh;
                        epoch_id(k,2:5)=pred9;
                        loss9=abs(epoch_id(k,2:5)-gt(1:4))+loss9;
                        w_de_x(k)=abs(pred9(1)-gt(1))+w_de_x(k);
                        w_de_y(k)=abs(pred9(2)-gt(2))+w_de_y(k);
                        w_de_w(k)=abs(pred9(3)-gt(3))+w_de_w(k);
                        w_de_h(k)=abs(pred9(4)-gt(4))+w_de_h(k);
                    end
                    for k=161:180
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred9);
                        IO=iou(pred_tblr,gt_tblr);
                        dwiou_de=dWIOU_de(pred9,gt);
                        pred9(1)=pred9(1)+0.01*(2-IO)*dwiou_de.dx;
                        pred9(2)=pred9(2)+0.01*(2-IO)*dwiou_de.dy;
                        pred9(3)=pred9(3)+0.01*(2-IO)*dwiou_de.dw;
                        pred9(4)=pred9(4)+0.01*(2-IO)*dwiou_de.dh;
                        epoch_id(k,2:5)=pred9;
                        loss9=abs(epoch_id(k,2:5)-gt(1:4))+loss9;
                        w_de_x(k)=abs(pred9(1)-gt(1))+w_de_x(k);
                        w_de_y(k)=abs(pred9(2)-gt(2))+w_de_y(k);
                        w_de_w(k)=abs(pred9(3)-gt(3))+w_de_w(k);
                        w_de_h(k)=abs(pred9(4)-gt(4))+w_de_h(k);
                    end
                    for k=181:200
                        gt_tblr=to_tblr(gt);
                        pred_tblr=to_tblr(pred9);
                        IO=iou(pred_tblr,gt_tblr);
                        dwiou_de=dWIOU_de(pred9,gt);
                        pred9(1)=pred9(1)+0.001*(2-IO)*dwiou_de.dx;
                        pred9(2)=pred9(2)+0.001*(2-IO)*dwiou_de.dy;
                        pred9(3)=pred9(3)+0.001*(2-IO)*dwiou_de.dw;
                        pred9(4)=pred9(4)+0.001*(2-IO)*dwiou_de.dh;
                        epoch_id(k,2:5)=pred9;
                        loss9=abs(epoch_id(k,2:5)-gt(1:4))+loss9;
                        w_de_x(k)=abs(pred9(1)-gt(1))+w_de_x(k);
                        w_de_y(k)=abs(pred9(2)-gt(2))+w_de_y(k);
                        w_de_w(k)=abs(pred9(3)-gt(3))+w_de_w(k);
                        w_de_h(k)=abs(pred9(4)-gt(4))+w_de_h(k);
                    end
                    final_error_wiou_de(mm1)=abs(pred9(1)-gt(1))+abs(pred9(2)-gt(2))+abs(pred9(3)-gt(3))+abs(pred9(4)-gt(4));
                    wiou_de0(l)=loss9(1)+loss9(2)+loss9(3)+loss9(4);
                    WIoU_de_Loss(mm1)=wiou_de0(l);
                    fprintf(F9, '%d\t',mm1);
                    fprintf(F9, '%f\t',position_x(mm1));
                    fprintf(F9, '%f\t',position_y(mm1));
                    fprintf(F9, '%f\t',position_w(mm1));
                    fprintf(F9, '%f\t',position_h(mm1));
                    fprintf(F9, '%f\t',WIoU_de_Loss(mm1));
                    fprintf(F9, '%f\n',final_error_wiou_de(mm1));				%save results for every regression cases

                end
            end
        end
    end
    fclose(F1);fclose(F2);fclose(F3);fclose(F4);fclose(F5);fclose(F6);fclose(F7);fclose(F8);fclose(F9);
    
    % This is the total error of 1715k regression cases in each epoch.
    iii=i_x+i_y+i_w+i_h;
    ggg=g_x+g_y+g_w+g_h;
    ddd=d_x+d_y+d_w+d_h;
    ccc=c_x+c_y+c_w+c_h;
    eee = e_x+e_y+e_w+e_h;
    ddd_de = d_de_x+d_de_y+d_de_w+d_de_h;
    eee_de = e_de_x+e_de_y+e_de_w+e_de_h;
    www = w_x+w_y+w_w+w_h;
    www_de = w_de_x+w_de_y+w_de_w+w_de_h;

    % Save the loss process of border regression to Excel
    xlswrite(excle_iou,iii,'sheet1','B2:B201');
    xlswrite(excle_iou,ggg,'sheet1','C2:C201');
    xlswrite(excle_iou,ddd,'sheet1','D2:D201');
    xlswrite(excle_iou,ccc,'sheet1','E2:E201');
    xlswrite(excle_iou,eee,'sheet1','F2:F201');
    xlswrite(excle_iou,ddd_de,'sheet1','G2:G201');
    xlswrite(excle_iou,eee_de,'sheet1','H2:H201');
    xlswrite(excle_iou,www,'sheet1','I2:I201');
    xlswrite(excle_iou,www_de,'sheet1','J2:J201');
    
    % plot regression error curve
    figure,plot(iii,'LineWidth',1.5);hold on
    plot(ggg,'LineWidth',1.5);hold on
    plot(ddd,'LineWidth',1.5);hold on
    plot(ccc,'LineWidth',1.5);hold on
    plot(eee,'LineWidth',1.5);hold on
    plot(www,'LineWidth',1.5);hold on
    plot(ddd_de,'LineWidth',1.5);hold on
    plot(eee_de,'color',getColor(1,10),'LineWidth',1.5);hold on
    plot(www_de,'color',getColor(5,10),'LineWidth',1.5),legend('IoU','GIoU','DIoU','CIoU','EIoU','WIoU','DIoU-de','EIoU-de','WIoU-de'),xlabel('Iteration'),ylabel('error');
    
    fxy_iou=zeros(5000,1,'double');
    fxy_giou=zeros(5000,1,'double');
    fxy_diou=zeros(5000,1,'double');
    fxy_ciou=zeros(5000,1,'double');
    fxy_eiou=zeros(5000,1,'double');
    fxy_diou_de=zeros(5000,1,'double');
    fxy_eiou_de=zeros(5000,1,'double');
    fxy_wiou=zeros(5000,1,'double');
    fxy_wiou_de=zeros(5000,1,'double');

    for u=1:5000
        for v=1:343
            n=(u-1)*343+v;
            fxy_iou(u)=fxy_iou(u)+final_error_iou(n);
            fxy_giou(u)=fxy_giou(u)+final_error_giou(n);
            fxy_diou(u)=fxy_diou(u)+final_error_diou(n);
            fxy_ciou(u)=fxy_ciou(u)+final_error_ciou(n);
            fxy_eiou(u)=fxy_eiou(u)+final_error_eiou(n);
            fxy_diou_de(u)=fxy_diou_de(u)+final_error_diou_de(n);
            fxy_eiou_de(u)=fxy_eiou_de(u)+final_error_eiou_de(n);
            fxy_wiou(u)=fxy_wiou(u)+final_error_wiou(n);
            fxy_wiou_de(u)=fxy_wiou_de(u)+final_error_wiou_de(n);
        end
    end
    
    %plot point cloud map of regression error
    tri = delaunay(xx,yy);
    figure,trimesh(tri,xx,yy,fxy_iou),zlabel('total final error'); 
    figure,trimesh(tri,xx,yy,fxy_giou),zlabel('total final error'); 
    figure,trimesh(tri,xx,yy,fxy_diou),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_ciou),zlabel('total final error');
    figure,trimesh(tri,xx,yy,fxy_eiou),zlabel('total final error');
    figure,trimesh(tri,xx,yy,fxy_diou_de),zlabel('total final error');     
    figure,trimesh(tri,xx,yy,fxy_eiou_de),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_wiou),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_wiou_de),zlabel('total final error');  

    F11=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\iou_reg.txt','a');
    F22=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\giou_reg.txt','a');
    F33=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\diou_reg.txt','a');
    F44=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\ciou_reg.txt','a');
    F55=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\eiou_reg.txt','a');
    F66=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\diou_de_reg.txt','a');
    F77=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\eiou_de_reg.txt','a');
    F88=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\wiou_reg.txt','a');
    F99=fopen('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\wiou_de_reg.txt','a');

    for v=1:200
        fprintf(F11, '%d\t',v);
        fprintf(F11, '%f\t',i_x(v));
        fprintf(F11, '%f\t',i_y(v));
        fprintf(F11, '%f\t',i_w(v));
        fprintf(F11, '%f\t',i_h(v));
        fprintf(F11, '%f\n',iii(v));
        fprintf(F22, '%d\t',v);
        fprintf(F22, '%f\t',g_x(v));
        fprintf(F22, '%f\t',g_y(v));
        fprintf(F22, '%f\t',g_w(v));
        fprintf(F22, '%f\t',g_h(v));
        fprintf(F22, '%f\n',ggg(v));
        fprintf(F33, '%d\t',v);
        fprintf(F33, '%f\t',d_x(v));
        fprintf(F33, '%f\t',d_y(v));
        fprintf(F33, '%f\t',d_w(v));
        fprintf(F33, '%f\t',d_h(v));
        fprintf(F33, '%f\n',ddd(v));
        fprintf(F44, '%d\t',v);
        fprintf(F44, '%f\t',c_x(v));
        fprintf(F44, '%f\t',c_y(v));
        fprintf(F44, '%f\t',c_w(v));
        fprintf(F44, '%f\t',c_h(v));
        fprintf(F44, '%f\n',ccc(v));
        fprintf(F55, '%d\t',v);
        fprintf(F55, '%f\t',e_x(v));
        fprintf(F55, '%f\t',e_y(v));
        fprintf(F55, '%f\t',e_w(v));
        fprintf(F55, '%f\t',e_h(v));
        fprintf(F55, '%f\n',eee(v));
        fprintf(F66, '%d\t',v);
        fprintf(F66, '%f\t',d_de_x(v));
        fprintf(F66, '%f\t',d_de_y(v));
        fprintf(F66, '%f\t',d_de_w(v));
        fprintf(F66, '%f\t',d_de_h(v));
        fprintf(F66, '%f\n',ddd_de(v));
        fprintf(F77, '%d\t',v);
        fprintf(F77, '%f\t',e_de_x(v));
        fprintf(F77, '%f\t',e_de_y(v));
        fprintf(F77, '%f\t',e_de_w(v));
        fprintf(F77, '%f\t',e_de_h(v));
        fprintf(F77, '%f\n',eee_de(v));
        fprintf(F88, '%d\t',v);
        fprintf(F88, '%f\t',w_x(v));
        fprintf(F88, '%f\t',w_y(v));
        fprintf(F88, '%f\t',w_w(v));
        fprintf(F88, '%f\t',w_h(v));
        fprintf(F88, '%f\n',www(v));
        fprintf(F99, '%d\t',v);
        fprintf(F99, '%f\t',w_de_x(v));
        fprintf(F99, '%f\t',w_de_y(v));
        fprintf(F99, '%f\t',w_de_w(v));
        fprintf(F99, '%f\t',w_de_h(v));
        fprintf(F99, '%f\n',www_de(v));
    end
    fclose(F11);
    fclose(F22);
    fclose(F33);
    fclose(F44);
    fclose(F55);
    fclose(F66);
    fclose(F77);
    fclose(F88);
    fclose(F99);
end

%--------------------------the following is to redraw  from previous results----------------------------%
if is_regresion==0
    fprintf('Processing regresion_process.m ...\n');
    [i1,i2,i3,i4,i5,i6,i7]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\iou-1715k.txt','%d%f%f%f%f%f%f');
    [g1,g2,g3,g4,g5,g6,g7]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\giou-1715k.txt','%d%f%f%f%f%f%f');
    [d1,d2,d3,d4,d5,d6,d7]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\diou-1715k.txt','%d%f%f%f%f%f%f');
    [c1,c2,c3,c4,c5,c6,c7]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\ciou-1715k.txt','%d%f%f%f%f%f%f');
    [e1,e2,e3,e4,e5,e6,e7]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\eiou-1715k.txt','%d%f%f%f%f%f%f');
    [d_de1,d_de2,d_de3,d_de4,d_de5,d_de6,d_de7]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\diou_de-1715k.txt','%d%f%f%f%f%f%f');
    [e_de1,e_de2,e_de3,e_de4,e_de5,e_de6,e_de7]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\eiou_de-1715k.txt','%d%f%f%f%f%f%f');
    [w1,w2,w3,w4,w5,w6,w7]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\wiou-1715k.txt','%d%f%f%f%f%f%f');
    [w_de1,w_de2,w_de3,w_de4,w_de5,w_de6,w_de7]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\wiou_de-1715k.txt','%d%f%f%f%f%f%f');

    fxy_iou=zeros(5000,1,'double');
    fxy_giou=zeros(5000,1,'double');
    fxy_diou=zeros(5000,1,'double');
    fxy_ciou=zeros(5000,1,'double');
    fxy_eiou=zeros(5000,1,'double');
    fxy_diou_de=zeros(5000,1,'double');
    fxy_eiou_de=zeros(5000,1,'double');
    fxy_wiou=zeros(5000,1,'double');
    fxy_wiou_de=zeros(5000,1,'double');

    for u=1:5000
        xx(u)=i2(u*343);
        yy(u)=i3(u*343);
        for v=1:343
            n=(u-1)*343+v;
            fxy_iou(u)=fxy_iou(u)+i7(n);
            fxy_giou(u)=fxy_giou(u)+g7(n);
            fxy_diou(u)=fxy_diou(u)+d7(n);
            fxy_ciou(u)=fxy_ciou(u)+c7(n);
            fxy_eiou(u)=fxy_eiou(u)+e7(n);
            fxy_diou_de(u)=fxy_diou_de(u)+d_de7(n);
            fxy_eiou_de(u)=fxy_eiou_de(u)+e_de7(n);
            fxy_wiou(u)=fxy_wiou(u)+w7(n);
            fxy_wiou_de(u)=fxy_wiou_de(u)+w_de7(n);
        end
    end
    %plot point cloud map of regression error
    tri = delaunay(xx,yy);
    figure,trimesh(tri,xx,yy,fxy_iou),zlabel('total final error'); 
    figure,trimesh(tri,xx,yy,fxy_giou),zlabel('total final error'); 
    figure,trimesh(tri,xx,yy,fxy_diou),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_ciou),zlabel('total final error');
    figure,trimesh(tri,xx,yy,fxy_eiou),zlabel('total final error');
    figure,trimesh(tri,xx,yy,fxy_diou_de),zlabel('total final error');     
    figure,trimesh(tri,xx,yy,fxy_eiou_de),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_wiou),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_wiou_de),zlabel('total final error');  

    [ii1,ii2,ii3,ii4,ii5,ii6]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\iou_reg.txt','%d%f%f%f%f%f');
    [gg1,gg2,gg3,gg4,gg5,gg6]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\giou_reg.txt','%d%f%f%f%f%f');
    [dd1,dd2,dd3,dd4,dd5,dd6]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\diou_reg.txt','%d%f%f%f%f%f');
    [cc1,cc2,cc3,cc4,cc5,cc6]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\ciou_reg.txt','%d%f%f%f%f%f');
    [ee1,ee2,ee3,ee4,ee5,ee6]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\eiou_reg.txt','%d%f%f%f%f%f');
    [dd_de1,dd_de2,dd_de3,dd_de4,dd_de5,dd_de6]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\diou_de_reg.txt','%d%f%f%f%f%f');
    [ee_de_1,ee_de_2,ee_de_3,ee_de_4,ee_de_5,ee_de_6]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\eiou_de_reg.txt','%d%f%f%f%f%f');
    [ww1,ww2,ww3,ww4,ww5,ww6]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\wiou_reg.txt','%d%f%f%f%f%f');
    [ww_de1,ww_de2,ww_de3,ww_de4,ww_de5,ww_de6]=textread('E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\wiou_de_reg.txt','%d%f%f%f%f%f');
    
    % Save the loss process of border regression to Excel
    excle_iou = 'E:\ReferncePaper\AIoU-expriments\AIoU-master\simulation experiments\results\iou-1715k.xls';
    iii = xlsread(excle_iou,'sheet1','B2:B201');
    ggg = xlsread(excle_iou,'sheet1','C2:C201');
    ddd = xlsread(excle_iou,'sheet1','D2:D201');
    ccc = xlsread(excle_iou,'sheet1','E2:E201');
    eee = xlsread(excle_iou,'sheet1','F2:F201');
    ddd_de = xlsread(excle_iou,'sheet1','G2:G201');
    eee_de = xlsread(excle_iou,'sheet1','H2:H201');
    www = xlsread(excle_iou,'sheet1','I2:I201');
    www_de = xlsread(excle_iou,'sheet1','J2:J201');
    
    maker_idx = 1:20:200;
    figure,plot(iii,'-o','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(ggg,'-diamond','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(ddd,'-*','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(ccc,'-+','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(eee,'-x','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(www,'-pentagram','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(ddd_de,'-^','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(eee_de,'-<','MarkerIndices',maker_idx,'color',getColor(5,10),'LineWidth',1.5);hold on
    plot(www_de,'->','MarkerIndices',maker_idx,'color',getColor(10,10),'LineWidth',1.5),legend('IoU','GIoU','DIoU','CIoU','EIoU','WIoU','DIoU-de','EIoU-de','WIoU-de'),xlabel('Iteration'),ylabel('error'); 
    
end
