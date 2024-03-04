clear
clc

is_regresion = 1;  % If not regression, use the previous results directly to draw a graph
learning_rate = 0.18;
epoch_num = 200;   % How many eopchs are returned in total
epoch_count = epoch_num*0.75;   % Display the regression border of the epochs in the order
excle_iou = 'E:\AIoU-master\results\3-dx-iou_loss-ss.xls';
excle_predect = 'E:\AIoU-master\results\3-dx-predect_box-ss.xls';
if is_regresion==1
    fprintf('Processing regresion_process.m ...\n');
    
    % define it for whatever you want, [x,y,w,h]
    gt=[10,10,6,4];
    pred=[10,5,3.5,5];
    
    count1=zeros(epoch_num,1,'int32');
    count2=zeros(epoch_num*4,1,'int32');
    for id=1:epoch_num
        count1(id)=id;
    end
    for id=1:epoch_num
        count2((id-1)*4+1)=id;
        count2((id-1)*4+2)=id;
        count2((id-1)*4+3)=id;
        count2((id-1)*4+4)=id;
    end

    % Establish Excel to record the regression process for iou_error and predict_box, and write them into row and column names
    xlswrite(excle_iou,{'name','iou','giou','diou','ciou','eiou','diou_de','eiou_de','wiou','wiou_de','GT','initial_pred'},'sheet1','A1:L1');
    excel_codination = sprintf('%s%d:%s%d','A',2,'A',epoch_num+1);
    xlswrite(excle_iou,count1,'sheet1',excel_codination);

    xlswrite(excle_iou,[gt(1);gt(2);gt(3);gt(4)],'sheet1','K2:K5');
    xlswrite(excle_iou,[pred_x;pred_y;pred_w;pred_h],'sheet1','L2:L5');

  
    xlswrite(excle_predect,{'name','iou','giou','diou','ciou','eiou','diou_de','eiou_de','wiou','wiou_de','GT','initial_pred'},'sheet1','A1:L1');
    excel_codination = sprintf('%s%d:%s%d','A',2,'A',epoch_num*4+1);
    xlswrite(excle_predect,count2,'sheet1',excel_codination);

    xlswrite(excle_predect,[gt(1);gt(2);gt(3);gt(4)],'sheet1','K2:K5');
    xlswrite(excle_predect,[pred_x;pred_y;pred_w;pred_h],'sheet1','L2:L5');


    i_x=zeros(epoch_num,1,'double');i_y=zeros(epoch_num,1,'double');i_w=zeros(epoch_num,1,'double');i_h=zeros(epoch_num,1,'double');
    g_x=zeros(epoch_num,1,'double');g_y=zeros(epoch_num,1,'double');g_w=zeros(epoch_num,1,'double');g_h=zeros(epoch_num,1,'double');
    d_x=zeros(epoch_num,1,'double');d_y=zeros(epoch_num,1,'double');d_w=zeros(epoch_num,1,'double');d_h=zeros(epoch_num,1,'double');
    c_x=zeros(epoch_num,1,'double');c_y=zeros(epoch_num,1,'double');c_w=zeros(epoch_num,1,'double');c_h=zeros(epoch_num,1,'double');
    e_x=zeros(epoch_num,1,'double');e_y=zeros(epoch_num,1,'double');e_w=zeros(epoch_num,1,'double');e_h=zeros(epoch_num,1,'double');
    d_de_x=zeros(epoch_num,1,'double');d_de_y=zeros(epoch_num,1,'double');d_de_w=zeros(epoch_num,1,'double');d_de_h=zeros(epoch_num,1,'double');
    e_de_x=zeros(epoch_num,1,'double');e_de_y=zeros(epoch_num,1,'double');e_de_w=zeros(epoch_num,1,'double');e_de_h=zeros(epoch_num,1,'double');
    w_x=zeros(epoch_num,1,'double');w_y=zeros(epoch_num,1,'double');w_w=zeros(epoch_num,1,'double');w_h=zeros(epoch_num,1,'double');
    w_de_x=zeros(epoch_num,1,'double');w_de_y=zeros(epoch_num,1,'double');w_de_w=zeros(epoch_num,1,'double');w_de_h=zeros(epoch_num,1,'double');
    fprintf('初始化完成\nlearning_rate:%d\nepoch:%d\n',learning_rate,epoch_num);
    
    position_x=pred_x;
    position_y=pred_y;
    position_w=pred_w;
    position_h=pred_h;
    
    
    pred1=pred;
    a=zeros(epoch_num,4,'double');
    loss1=zeros(1,4,'double');
    for k=1:(epoch_num*0.7)	
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred1);
        IO=iou(pred_tblr,gt_tblr);
        diou=dIOU(pred_tblr,gt_tblr);
        diou_xywh=to_xywh(diou);
        pred1(1)=pred1(1)+learning_rate*(2-IO)*diou_xywh.dx;
        pred1(2)=pred1(2)+learning_rate*(2-IO)*diou_xywh.dy;
        pred1(3)=pred1(3)+learning_rate*(2-IO)*diou_xywh.dw;
        pred1(4)=pred1(4)+learning_rate*(2-IO)*diou_xywh.dh;
        a(k,2:5)=pred1;
        loss1=abs(a(k,2:5)-gt(1:4))+loss1;
        i_x(k)=abs(pred1(1)-gt(1))+i_x(k);
        i_y(k)=abs(pred1(2)-gt(2))+i_y(k);
        i_w(k)=abs(pred1(3)-gt(3))+i_w(k);
        i_h(k)=abs(pred1(4)-gt(4))+i_h(k);

        excel_codination = sprintf('%s%d:%s%d','B',(k-1)*4+2,'B',k*4+1);
        xlswrite(excle_predect,[pred1(1);pred1(2);pred1(3);pred1(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.7+1):(epoch_num*0.9)	
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred1);
        IO=iou(pred_tblr,gt_tblr);
        diou=dIOU(pred_tblr,gt_tblr);
        diou_xywh=to_xywh(diou);
        pred1(1)=pred1(1)+learning_rate*0.25*(2-IO)*diou_xywh.dx;
        pred1(2)=pred1(2)+learning_rate*0.25*(2-IO)*diou_xywh.dy;
        pred1(3)=pred1(3)+learning_rate*0.25*(2-IO)*diou_xywh.dw;
        pred1(4)=pred1(4)+learning_rate*0.25*(2-IO)*diou_xywh.dh;
        a(k,2:5)=pred1;
        loss1=abs(a(k,2:5)-gt(1:4))+loss1;
        i_x(k)=abs(pred1(1)-gt(1))+i_x(k);
        i_y(k)=abs(pred1(2)-gt(2))+i_y(k);
        i_w(k)=abs(pred1(3)-gt(3))+i_w(k);
        i_h(k)=abs(pred1(4)-gt(4))+i_h(k);

        excel_codination = sprintf('%s%d:%s%d','B',(k-1)*4+2,'B',k*4+1);
        xlswrite(excle_predect,[pred1(1);pred1(2);pred1(3);pred1(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.9+1):epoch_num
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred1);
        IO=iou(pred_tblr,gt_tblr);
        diou=dIOU(pred_tblr,gt_tblr);
        diou_xywh=to_xywh(diou);
        pred1(1)=pred1(1)+learning_rate*0.02*(2-IO)*diou_xywh.dx;
        pred1(2)=pred1(2)+learning_rate*0.02*(2-IO)*diou_xywh.dy;
        pred1(3)=pred1(3)+learning_rate*0.02*(2-IO)*diou_xywh.dw;
        pred1(4)=pred1(4)+learning_rate*0.02*(2-IO)*diou_xywh.dh;
        a(k,2:5)=pred1;
        loss1=abs(a(k,2:5)-gt(1:4))+loss1;
        i_x(k)=abs(pred1(1)-gt(1))+i_x(k);
        i_y(k)=abs(pred1(2)-gt(2))+i_y(k);
        i_w(k)=abs(pred1(3)-gt(3))+i_w(k);
        i_h(k)=abs(pred1(4)-gt(4))+i_h(k);

        excel_codination = sprintf('%s%d:%s%d','B',(k-1)*4+2,'B',k*4+1);
        xlswrite(excle_predect,[pred1(1);pred1(2);pred1(3);pred1(4)],'sheet1',excel_codination);
    end
    final_error_iou=abs(pred1(1)-gt(1))+abs(pred1(2)-gt(2))+abs(pred1(3)-gt(3))+abs(pred1(4)-gt(4));
    iou0=loss1(1)+loss1(2)+loss1(3)+loss1(4);
    IoU_Loss=iou0;

    fprintf('Complete the regression of iou\n');

    pred2=pred;
    a=zeros(epoch_num,4,'double');
    loss2=zeros(1,4,'double');
    for k=1:(epoch_num*0.7)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred2);
        IO=iou(pred_tblr,gt_tblr);
        dgiou=dGIOU(pred_tblr,gt_tblr);
        dgiou_xywh=to_xywh(dgiou);
        pred2(1)=pred2(1)+learning_rate*(2-IO)*dgiou_xywh.dx;
        pred2(2)=pred2(2)+learning_rate*(2-IO)*dgiou_xywh.dy;
        pred2(3)=pred2(3)+learning_rate*(2-IO)*dgiou_xywh.dw;
        pred2(4)=pred2(4)+learning_rate*(2-IO)*dgiou_xywh.dh;
        a(k,2:5)=pred2;
        loss2=abs(a(k,2:5)-gt(1:4))+loss2;
        g_x(k)=abs(pred2(1)-gt(1))+g_x(k);
        g_y(k)=abs(pred2(2)-gt(2))+g_y(k);
        g_w(k)=abs(pred2(3)-gt(3))+g_w(k);
        g_h(k)=abs(pred2(4)-gt(4))+g_h(k);

        excel_codination = sprintf('%s%d:%s%d','C',(k-1)*4+2,'C',k*4+1);
        xlswrite(excle_predect,[pred2(1);pred2(2);pred2(3);pred2(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.7+1):(epoch_num*0.9)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred2);
        IO=iou(pred_tblr,gt_tblr);
        dgiou=dGIOU(pred_tblr,gt_tblr);
        dgiou_xywh=to_xywh(dgiou);
        pred2(1)=pred2(1)+learning_rate*0.25*(2-IO)*dgiou_xywh.dx;
        pred2(2)=pred2(2)+learning_rate*0.25*(2-IO)*dgiou_xywh.dy;
        pred2(3)=pred2(3)+learning_rate*0.25*(2-IO)*dgiou_xywh.dw;
        pred2(4)=pred2(4)+learning_rate*0.25*(2-IO)*dgiou_xywh.dh;
        a(k,2:5)=pred2;
        loss2=abs(a(k,2:5)-gt(1:4))+loss2;
        g_x(k)=abs(pred2(1)-gt(1))+g_x(k);
        g_y(k)=abs(pred2(2)-gt(2))+g_y(k);
        g_w(k)=abs(pred2(3)-gt(3))+g_w(k);
        g_h(k)=abs(pred2(4)-gt(4))+g_h(k);

        excel_codination = sprintf('%s%d:%s%d','C',(k-1)*4+2,'C',k*4+1);
        xlswrite(excle_predect,[pred2(1);pred2(2);pred2(3);pred2(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.9+1):epoch_num
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred2);
        IO=iou(pred_tblr,gt_tblr);
        dgiou=dGIOU(pred_tblr,gt_tblr);
        dgiou_xywh=to_xywh(dgiou);
        pred2(1)=pred2(1)+learning_rate*0.02*(2-IO)*dgiou_xywh.dx;
        pred2(2)=pred2(2)+learning_rate*0.02*(2-IO)*dgiou_xywh.dy;
        pred2(3)=pred2(3)+learning_rate*0.02*(2-IO)*dgiou_xywh.dw;
        pred2(4)=pred2(4)+learning_rate*0.02*(2-IO)*dgiou_xywh.dh;
        a(k,2:5)=pred2;
        loss2=abs(a(k,2:5)-gt(1:4))+loss2;
        g_x(k)=abs(pred2(1)-gt(1))+g_x(k);
        g_y(k)=abs(pred2(2)-gt(2))+g_y(k);
        g_w(k)=abs(pred2(3)-gt(3))+g_w(k);
        g_h(k)=abs(pred2(4)-gt(4))+g_h(k);

        excel_codination = sprintf('%s%d:%s%d','C',(k-1)*4+2,'C',k*4+1);
        xlswrite(excle_predect,[pred2(1);pred2(2);pred2(3);pred2(4)],'sheet1',excel_codination);
    end
    final_error_giou=abs(pred2(1)-gt(1))+abs(pred2(2)-gt(2))+abs(pred2(3)-gt(3))+abs(pred2(4)-gt(4));
    giou0=loss2(1)+loss2(2)+loss2(3)+loss2(4);
    GIoU_Loss=giou0;

    fprintf('Complete the regression of giou\n');

    pred3=pred;
    a=zeros(epoch_num,4,'double');
    loss3=zeros(1,4,'double');
    for k=1:(epoch_num*0.7)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred3);
        IO=iou(pred_tblr,gt_tblr);
        ddiou=dDIOU(pred3,gt);
        pred3(1)=pred3(1)+learning_rate*(2-IO)*ddiou.dx;
        pred3(2)=pred3(2)+learning_rate*(2-IO)*ddiou.dy;
        pred3(3)=pred3(3)+learning_rate*(2-IO)*ddiou.dw;
        pred3(4)=pred3(4)+learning_rate*(2-IO)*ddiou.dh;
        a(k,2:5)=pred3;
        loss3=abs(a(k,2:5)-gt(1:4))+loss3;
        d_x(k)=abs(pred3(1)-gt(1))+d_x(k);
        d_y(k)=abs(pred3(2)-gt(2))+d_y(k);
        d_w(k)=abs(pred3(3)-gt(3))+d_w(k);
        d_h(k)=abs(pred3(4)-gt(4))+d_h(k);

        excel_codination = sprintf('%s%d:%s%d','D',(k-1)*4+2,'D',k*4+1);
        xlswrite(excle_predect,[pred3(1);pred3(2);pred3(3);pred3(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.7+1):(epoch_num*0.9)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred3);
        IO=iou(pred_tblr,gt_tblr);
        ddiou=dDIOU(pred3,gt);
        pred3(1)=pred3(1)+learning_rate*0.25*(2-IO)*ddiou.dx;
        pred3(2)=pred3(2)+learning_rate*0.25*(2-IO)*ddiou.dy;
        pred3(3)=pred3(3)+learning_rate*0.25*(2-IO)*ddiou.dw;
        pred3(4)=pred3(4)+learning_rate*0.25*(2-IO)*ddiou.dh;
        a(k,2:5)=pred3;
        loss3=abs(a(k,2:5)-gt(1:4))+loss3;
        d_x(k)=abs(pred3(1)-gt(1))+d_x(k);
        d_y(k)=abs(pred3(2)-gt(2))+d_y(k);
        d_w(k)=abs(pred3(3)-gt(3))+d_w(k);
        d_h(k)=abs(pred3(4)-gt(4))+d_h(k);

        excel_codination = sprintf('%s%d:%s%d','D',(k-1)*4+2,'D',k*4+1);
        xlswrite(excle_predect,[pred3(1);pred3(2);pred3(3);pred3(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.9+1):epoch_num
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred3);
        IO=iou(pred_tblr,gt_tblr);
        ddiou=dDIOU(pred3,gt);
        pred3(1)=pred3(1)+learning_rate*0.02*(2-IO)*ddiou.dx;
        pred3(2)=pred3(2)+learning_rate*0.02*(2-IO)*ddiou.dy;
        pred3(3)=pred3(3)+learning_rate*0.02*(2-IO)*ddiou.dw;
        pred3(4)=pred3(4)+learning_rate*0.02*(2-IO)*ddiou.dh;
        a(k,2:5)=pred3;
        loss3=abs(a(k,2:5)-gt(1:4))+loss3;
        d_x(k)=abs(pred3(1)-gt(1))+d_x(k);
        d_y(k)=abs(pred3(2)-gt(2))+d_y(k);
        d_w(k)=abs(pred3(3)-gt(3))+d_w(k);
        d_h(k)=abs(pred3(4)-gt(4))+d_h(k);

        excel_codination = sprintf('%s%d:%s%d','D',(k-1)*4+2,'D',k*4+1);
        xlswrite(excle_predect,[pred3(1);pred3(2);pred3(3);pred3(4)],'sheet1',excel_codination);
    end
    final_error_diou=abs(pred3(1)-gt(1))+abs(pred3(2)-gt(2))+abs(pred3(3)-gt(3))+abs(pred3(4)-gt(4));
    diou0=loss3(1)+loss3(2)+loss3(3)+loss3(4);
    DIoU_Loss=diou0;

    fprintf('Complete the regression of diou\n');

    pred4=pred;
    a=zeros(epoch_num,4,'double');
    loss4=zeros(1,4,'double');
    for k=1:(epoch_num*0.7)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred4);
        IO=iou(pred_tblr,gt_tblr);
        dciou=dCIOU(pred4,gt);
        pred4(1)=pred4(1)+learning_rate*(2-IO)*dciou.dx;
        pred4(2)=pred4(2)+learning_rate*(2-IO)*dciou.dy;
        pred4(3)=pred4(3)+learning_rate*(2-IO)*dciou.dw;
        pred4(4)=pred4(4)+learning_rate*(2-IO)*dciou.dh;
        a(k,2:5)=pred4;
        loss4=abs(a(k,2:5)-gt(1:4))+loss4;
        c_x(k)=abs(pred4(1)-gt(1))+c_x(k);
        c_y(k)=abs(pred4(2)-gt(2))+c_y(k);
        c_w(k)=abs(pred4(3)-gt(3))+c_w(k);
        c_h(k)=abs(pred4(4)-gt(4))+c_h(k);

        excel_codination = sprintf('%s%d:%s%d','E',(k-1)*4+2,'E',k*4+1);
        xlswrite(excle_predect,[pred4(1);pred4(2);pred4(3);pred4(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.7+1):(epoch_num*0.9)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred4);
        IO=iou(pred_tblr,gt_tblr);
        dciou=dCIOU(pred4,gt);
        pred4(1)=pred4(1)+learning_rate*0.25*(2-IO)*dciou.dx;
        pred4(2)=pred4(2)+learning_rate*0.25*(2-IO)*dciou.dy;
        pred4(3)=pred4(3)+learning_rate*0.25*(2-IO)*dciou.dw;
        pred4(4)=pred4(4)+learning_rate*0.25*(2-IO)*dciou.dh;
        a(k,2:5)=pred4;
        loss4=abs(a(k,2:5)-gt(1:4))+loss4;
        c_x(k)=abs(pred4(1)-gt(1))+c_x(k);
        c_y(k)=abs(pred4(2)-gt(2))+c_y(k);
        c_w(k)=abs(pred4(3)-gt(3))+c_w(k);
        c_h(k)=abs(pred4(4)-gt(4))+c_h(k);

        excel_codination = sprintf('%s%d:%s%d','E',(k-1)*4+2,'E',k*4+1);
        xlswrite(excle_predect,[pred4(1);pred4(2);pred4(3);pred4(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.9+1):epoch_num
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred4);
        IO=iou(pred_tblr,gt_tblr);
        dciou=dCIOU(pred4,gt);
        pred4(1)=pred4(1)+learning_rate*0.02*(2-IO)*dciou.dx;
        pred4(2)=pred4(2)+learning_rate*0.02*(2-IO)*dciou.dy;
        pred4(3)=pred4(3)+learning_rate*0.02*(2-IO)*dciou.dw;
        pred4(4)=pred4(4)+learning_rate*0.02*(2-IO)*dciou.dh;
        a(k,2:5)=pred4;
        loss4=abs(a(k,2:5)-gt(1:4))+loss4;
        c_x(k)=abs(pred4(1)-gt(1))+c_x(k);
        c_y(k)=abs(pred4(2)-gt(2))+c_y(k);
        c_w(k)=abs(pred4(3)-gt(3))+c_w(k);
        c_h(k)=abs(pred4(4)-gt(4))+c_h(k);

        excel_codination = sprintf('%s%d:%s%d','E',(k-1)*4+2,'E',k*4+1);
        xlswrite(excle_predect,[pred4(1);pred4(2);pred4(3);pred4(4)],'sheet1',excel_codination);
    end
    final_error_ciou=abs(pred4(1)-gt(1))+abs(pred4(2)-gt(2))+abs(pred4(3)-gt(3))+abs(pred4(4)-gt(4));
    ciou0=loss4(1)+loss4(2)+loss4(3)+loss4(4);
    CIoU_Loss=ciou0;

    fprintf('Complete the regression of ciou\n');

    pred5=pred;
    a=zeros(epoch_num,4,'double');
    loss5=zeros(1,4,'double');
    for k=1:(epoch_num*0.7)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred5);
        IO=iou(pred_tblr,gt_tblr);
        deiou=dEIOU(pred5,gt);
        pred5(1)=pred5(1)+learning_rate*(2-IO)*deiou.dx;
        pred5(2)=pred5(2)+learning_rate*(2-IO)*deiou.dy;
        pred5(3)=pred5(3)+learning_rate*(2-IO)*deiou.dw;
        pred5(4)=pred5(4)+learning_rate*(2-IO)*deiou.dh;
        a(k,2:5)=pred5;
        loss5=abs(a(k,2:5)-gt(1:4))+loss5;
        e_x(k)=abs(pred5(1)-gt(1))+e_x(k);
        e_y(k)=abs(pred5(2)-gt(2))+e_y(k);
        e_w(k)=abs(pred5(3)-gt(3))+e_w(k);
        e_h(k)=abs(pred5(4)-gt(4))+e_h(k);

        excel_codination = sprintf('%s%d:%s%d','F',(k-1)*4+2,'F',k*4+1);
        xlswrite(excle_predect,[pred5(1);pred5(2);pred5(3);pred5(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.7+1):(epoch_num*0.9)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred5);
        IO=iou(pred_tblr,gt_tblr);
        deiou=dEIOU(pred5,gt);
        pred5(1)=pred5(1)+learning_rate*0.25*(2-IO)*deiou.dx;
        pred5(2)=pred5(2)+learning_rate*0.25*(2-IO)*deiou.dy;
        pred5(3)=pred5(3)+learning_rate*0.25*(2-IO)*deiou.dw;
        pred5(4)=pred5(4)+learning_rate*0.25*(2-IO)*deiou.dh;
        a(k,2:5)=pred5;
        loss5=abs(a(k,2:5)-gt(1:4))+loss5;
        e_x(k)=abs(pred5(1)-gt(1))+e_x(k);
        e_y(k)=abs(pred5(2)-gt(2))+e_y(k);
        e_w(k)=abs(pred5(3)-gt(3))+e_w(k);
        e_h(k)=abs(pred5(4)-gt(4))+e_h(k);

        excel_codination = sprintf('%s%d:%s%d','F',(k-1)*4+2,'F',k*4+1);
        xlswrite(excle_predect,[pred5(1);pred5(2);pred5(3);pred5(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.9+1):epoch_num
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred5);
        IO=iou(pred_tblr,gt_tblr);
        deiou=dEIOU(pred5,gt);
        pred5(1)=pred5(1)+learning_rate*0.02*(2-IO)*deiou.dx;
        pred5(2)=pred5(2)+learning_rate*0.02*(2-IO)*deiou.dy;
        pred5(3)=pred5(3)+learning_rate*0.02*(2-IO)*deiou.dw;
        pred5(4)=pred5(4)+learning_rate*0.02*(2-IO)*deiou.dh;
        a(k,2:5)=pred5;
        loss5=abs(a(k,2:5)-gt(1:4))+loss5;
        e_x(k)=abs(pred5(1)-gt(1))+e_x(k);
        e_y(k)=abs(pred5(2)-gt(2))+e_y(k);
        e_w(k)=abs(pred5(3)-gt(3))+e_w(k);
        e_h(k)=abs(pred5(4)-gt(4))+e_h(k);

        excel_codination = sprintf('%s%d:%s%d','F',(k-1)*4+2,'F',k*4+1);
        xlswrite(excle_predect,[pred5(1);pred5(2);pred5(3);pred5(4)],'sheet1',excel_codination);
    end
    final_error_eiou=abs(pred5(1)-gt(1))+abs(pred5(2)-gt(2))+abs(pred5(3)-gt(3))+abs(pred5(4)-gt(4));
    eiou0=loss5(1)+loss5(2)+loss5(3)+loss5(4);
    EIoU_Loss=eiou0;

    fprintf('Complete the regression of eiou\n');

    pred6=pred;
    a=zeros(epoch_num,4,'double');
    loss6=zeros(1,4,'double');
    for k=1:(epoch_num*0.7)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred6);
        IO=iou(pred_tblr,gt_tblr);
        ddiou_de=dDIOU_de(pred6,gt);
        pred6(1)=pred6(1)+learning_rate*(2-IO)*ddiou_de.dx;
        pred6(2)=pred6(2)+learning_rate*(2-IO)*ddiou_de.dy;
        pred6(3)=pred6(3)+learning_rate*(2-IO)*ddiou_de.dw;
        pred6(4)=pred6(4)+learning_rate*(2-IO)*ddiou_de.dh;
        a(k,2:5)=pred6;
        loss6=abs(a(k,2:5)-gt(1:4))+loss6;
        d_de_x(k)=abs(pred6(1)-gt(1))+d_de_x(k);
        d_de_y(k)=abs(pred6(2)-gt(2))+d_de_y(k);
        d_de_w(k)=abs(pred6(3)-gt(3))+d_de_w(k);
        d_de_h(k)=abs(pred6(4)-gt(4))+d_de_h(k);

        excel_codination = sprintf('%s%d:%s%d','G',(k-1)*4+2,'G',k*4+1);
        xlswrite(excle_predect,[pred6(1);pred6(2);pred6(3);pred6(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.7+1):(epoch_num*0.9)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred6);
        IO=iou(pred_tblr,gt_tblr);
        ddiou_de=dDIOU_de(pred6,gt);
        pred6(1)=pred6(1)+learning_rate*0.25*(2-IO)*ddiou_de.dx;
        pred6(2)=pred6(2)+learning_rate*0.25*(2-IO)*ddiou_de.dy;
        pred6(3)=pred6(3)+learning_rate*0.25*(2-IO)*ddiou_de.dw;
        pred6(4)=pred6(4)+learning_rate*0.25*(2-IO)*ddiou_de.dh;
        a(k,2:5)=pred6;
        loss6=abs(a(k,2:5)-gt(1:4))+loss6;
        d_de_x(k)=abs(pred6(1)-gt(1))+d_de_x(k);
        d_de_y(k)=abs(pred6(2)-gt(2))+d_de_y(k);
        d_de_w(k)=abs(pred6(3)-gt(3))+d_de_w(k);
        d_de_h(k)=abs(pred6(4)-gt(4))+d_de_h(k);

        excel_codination = sprintf('%s%d:%s%d','G',(k-1)*4+2,'G',k*4+1);
        xlswrite(excle_predect,[pred6(1);pred6(2);pred6(3);pred6(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.9+1):epoch_num
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred6);
        IO=iou(pred_tblr,gt_tblr);
        ddiou_de=dDIOU_de(pred6,gt);
        pred6(1)=pred6(1)+learning_rate*0.02*(2-IO)*ddiou_de.dx;
        pred6(2)=pred6(2)+learning_rate*0.02*(2-IO)*ddiou_de.dy;
        pred6(3)=pred6(3)+learning_rate*0.02*(2-IO)*ddiou_de.dw;
        pred6(4)=pred6(4)+learning_rate*0.02*(2-IO)*ddiou_de.dh;
        a(k,2:5)=pred6;
        loss6=abs(a(k,2:5)-gt(1:4))+loss6;
        d_de_x(k)=abs(pred6(1)-gt(1))+d_de_x(k);
        d_de_y(k)=abs(pred6(2)-gt(2))+d_de_y(k);
        d_de_w(k)=abs(pred6(3)-gt(3))+d_de_w(k);
        d_de_h(k)=abs(pred6(4)-gt(4))+d_de_h(k);

        excel_codination = sprintf('%s%d:%s%d','G',(k-1)*4+2,'G',k*4+1);
        xlswrite(excle_predect,[pred6(1);pred6(2);pred6(3);pred6(4)],'sheet1',excel_codination);
    end
    final_error_diou_de=abs(pred6(1)-gt(1))+abs(pred6(2)-gt(2))+abs(pred6(3)-gt(3))+abs(pred6(4)-gt(4));
    diou_de0=loss6(1)+loss6(2)+loss6(3)+loss6(4);
    DIoU_de_Loss=diou_de0;

    fprintf('Complete the regression of diou_de\n');

    pred7=pred;
    a=zeros(epoch_num,4,'double');
    loss7=zeros(1,4,'double');
    for k=1:(epoch_num*0.7)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred7);
        IO=iou(pred_tblr,gt_tblr);
        deiou_de=dEIOU_de(pred7,gt);
        pred7(1)=pred7(1)+learning_rate*(2-IO)*deiou_de.dx;
        pred7(2)=pred7(2)+learning_rate*(2-IO)*deiou_de.dy;
        pred7(3)=pred7(3)+learning_rate*(2-IO)*deiou_de.dw;
        pred7(4)=pred7(4)+learning_rate*(2-IO)*deiou_de.dh;
        a(k,2:5)=pred7;
        loss7=abs(a(k,2:5)-gt(1:4))+loss7;
        e_de_x(k)=abs(pred7(1)-gt(1))+e_de_x(k);
        e_de_y(k)=abs(pred7(2)-gt(2))+e_de_y(k);
        e_de_w(k)=abs(pred7(3)-gt(3))+e_de_w(k);
        e_de_h(k)=abs(pred7(4)-gt(4))+e_de_h(k);

        excel_codination = sprintf('%s%d:%s%d','H',(k-1)*4+2,'H',k*4+1);
        xlswrite(excle_predect,[pred7(1);pred7(2);pred7(3);pred7(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.7+1):(epoch_num*0.9)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred7);
        IO=iou(pred_tblr,gt_tblr);
        deiou_de=dEIOU_de(pred7,gt);
        pred7(1)=pred7(1)+learning_rate*0.25*(2-IO)*deiou_de.dx;
        pred7(2)=pred7(2)+learning_rate*0.25*(2-IO)*deiou_de.dy;
        pred7(3)=pred7(3)+learning_rate*0.25*(2-IO)*deiou_de.dw;
        pred7(4)=pred7(4)+learning_rate*0.25*(2-IO)*deiou_de.dh;
        a(k,2:5)=pred7;
        loss7=abs(a(k,2:5)-gt(1:4))+loss7;
        e_de_x(k)=abs(pred7(1)-gt(1))+e_de_x(k);
        e_de_y(k)=abs(pred7(2)-gt(2))+e_de_y(k);
        e_de_w(k)=abs(pred7(3)-gt(3))+e_de_w(k);
        e_de_h(k)=abs(pred7(4)-gt(4))+e_de_h(k);

        excel_codination = sprintf('%s%d:%s%d','H',(k-1)*4+2,'H',k*4+1);
        xlswrite(excle_predect,[pred7(1);pred7(2);pred7(3);pred7(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.9+1):epoch_num
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred7);
        IO=iou(pred_tblr,gt_tblr);
        deiou_de=dEIOU_de(pred7,gt);
        pred7(1)=pred7(1)+learning_rate*0.02*(2-IO)*deiou_de.dx;
        pred7(2)=pred7(2)+learning_rate*0.02*(2-IO)*deiou_de.dy;
        pred7(3)=pred7(3)+learning_rate*0.02*(2-IO)*deiou_de.dw;
        pred7(4)=pred7(4)+learning_rate*0.02*(2-IO)*deiou_de.dh;
        a(k,2:5)=pred7;
        loss7=abs(a(k,2:5)-gt(1:4))+loss7;
        e_de_x(k)=abs(pred7(1)-gt(1))+e_de_x(k);
        e_de_y(k)=abs(pred7(2)-gt(2))+e_de_y(k);
        e_de_w(k)=abs(pred7(3)-gt(3))+e_de_w(k);
        e_de_h(k)=abs(pred7(4)-gt(4))+e_de_h(k);

        excel_codination = sprintf('%s%d:%s%d','H',(k-1)*4+2,'H',k*4+1);
        xlswrite(excle_predect,[pred7(1);pred7(2);pred7(3);pred7(4)],'sheet1',excel_codination);
    end
    final_error_eiou_de=abs(pred7(1)-gt(1))+abs(pred7(2)-gt(2))+abs(pred7(3)-gt(3))+abs(pred7(4)-gt(4));
    eiou_de0=loss7(1)+loss7(2)+loss7(3)+loss7(4);
    EIoU_de_Loss=eiou_de0;

    fprintf('Complete the regression of eiou_de\n');
    

    % WIOU
    pred8=pred;
    a=zeros(epoch_num,4,'double');
    loss8=zeros(1,4,'double');
    for k=1:(epoch_num*0.7)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred8);
        IO=iou(pred_tblr,gt_tblr);
        dwiou=dWIOU(pred8,gt);
        pred8(1)=pred8(1)+learning_rate*(2-IO)*dwiou.dx;
        pred8(2)=pred8(2)+learning_rate*(2-IO)*dwiou.dy;
        pred8(3)=pred8(3)+learning_rate*(2-IO)*dwiou.dw;
        pred8(4)=pred8(4)+learning_rate*(2-IO)*dwiou.dh;
        a(k,2:5)=pred8;
        loss8=abs(a(k,2:5)-gt(1:4))+loss8;
        w_x(k)=abs(pred8(1)-gt(1))+w_x(k);
        w_y(k)=abs(pred8(2)-gt(2))+w_y(k);
        w_w(k)=abs(pred8(3)-gt(3))+w_w(k);
        w_h(k)=abs(pred8(4)-gt(4))+w_h(k);

        excel_codination = sprintf('%s%d:%s%d','I',(k-1)*4+2,'I',k*4+1);
        xlswrite(excle_predect,[pred8(1);pred8(2);pred8(3);pred8(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.7+1):(epoch_num*0.9)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred8);
        IO=iou(pred_tblr,gt_tblr);
        dwiou=dWIOU(pred8,gt);
        pred8(1)=pred8(1)+learning_rate*0.25*(2-IO)*dwiou.dx;
        pred8(2)=pred8(2)+learning_rate*0.25*(2-IO)*dwiou.dy;
        pred8(3)=pred8(3)+learning_rate*0.25*(2-IO)*dwiou.dw;
        pred8(4)=pred8(4)+learning_rate*0.25*(2-IO)*dwiou.dh;
        a(k,2:5)=pred8;
        loss8=abs(a(k,2:5)-gt(1:4))+loss8;
        w_x(k)=abs(pred8(1)-gt(1))+w_x(k);
        w_y(k)=abs(pred8(2)-gt(2))+w_y(k);
        w_w(k)=abs(pred8(3)-gt(3))+w_w(k);
        w_h(k)=abs(pred8(4)-gt(4))+w_h(k);

        excel_codination = sprintf('%s%d:%s%d','I',(k-1)*4+2,'I',k*4+1);
        xlswrite(excle_predect,[pred8(1);pred8(2);pred8(3);pred8(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.9+1):epoch_num
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred8);
        IO=iou(pred_tblr,gt_tblr);
        dwiou=dWIOU(pred8,gt);
        pred8(1)=pred8(1)+learning_rate*0.02*(2-IO)*dwiou.dx;
        pred8(2)=pred8(2)+learning_rate*0.02*(2-IO)*dwiou.dy;
        pred8(3)=pred8(3)+learning_rate*0.02*(2-IO)*dwiou.dw;
        pred8(4)=pred8(4)+learning_rate*0.02*(2-IO)*dwiou.dh;
        a(k,2:5)=pred8;
        loss8=abs(a(k,2:5)-gt(1:4))+loss8;
        w_x(k)=abs(pred8(1)-gt(1))+w_x(k);
        w_y(k)=abs(pred8(2)-gt(2))+w_y(k);
        w_w(k)=abs(pred8(3)-gt(3))+w_w(k);
        w_h(k)=abs(pred8(4)-gt(4))+w_h(k);

        excel_codination = sprintf('%s%d:%s%d','I',(k-1)*4+2,'I',k*4+1);
        xlswrite(excle_predect,[pred8(1);pred8(2);pred8(3);pred8(4)],'sheet1',excel_codination);
    end
    final_error_wiou=abs(pred8(1)-gt(1))+abs(pred8(2)-gt(2))+abs(pred8(3)-gt(3))+abs(pred8(4)-gt(4));
    wiou0=loss8(1)+loss8(2)+loss8(3)+loss8(4);
    WIoU_Loss=wiou0;

    fprintf('Complete the regression of wiou\n');
    
    % WIOU_de
    pred9=pred;
    a=zeros(epoch_num,4,'double');
    loss9=zeros(1,4,'double');
    for k=1:(epoch_num*0.7)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred9);
        IO=iou(pred_tblr,gt_tblr);
        dwiou_de=dWIOU_de(pred9,gt);
        pred9(1)=pred9(1)+learning_rate*(2-IO)*dwiou_de.dx;
        pred9(2)=pred9(2)+learning_rate*(2-IO)*dwiou_de.dy;
        pred9(3)=pred9(3)+learning_rate*(2-IO)*dwiou_de.dw;
        pred9(4)=pred9(4)+learning_rate*(2-IO)*dwiou_de.dh;
        a(k,2:5)=pred9;
        loss9=abs(a(k,2:5)-gt(1:4))+loss9;
        w_de_x(k)=abs(pred9(1)-gt(1))+w_de_x(k);
        w_de_y(k)=abs(pred9(2)-gt(2))+w_de_y(k);
        w_de_w(k)=abs(pred9(3)-gt(3))+w_de_w(k);
        w_de_h(k)=abs(pred9(4)-gt(4))+w_de_h(k);

        excel_codination = sprintf('%s%d:%s%d','J',(k-1)*4+2,'J',k*4+1);
        xlswrite(excle_predect,[pred9(1);pred9(2);pred9(3);pred9(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.7+1):(epoch_num*0.9)
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred9);
        IO=iou(pred_tblr,gt_tblr);
        dwiou_de=dWIOU_de(pred9,gt);
        pred9(1)=pred9(1)+learning_rate*0.25*(2-IO)*dwiou_de.dx;
        pred9(2)=pred9(2)+learning_rate*0.25*(2-IO)*dwiou_de.dy;
        pred9(3)=pred9(3)+learning_rate*0.25*(2-IO)*dwiou_de.dw;
        pred9(4)=pred9(4)+learning_rate*0.25*(2-IO)*dwiou_de.dh;
        a(k,2:5)=pred9;
        loss9=abs(a(k,2:5)-gt(1:4))+loss9;
        w_de_x(k)=abs(pred9(1)-gt(1))+w_de_x(k);
        w_de_y(k)=abs(pred9(2)-gt(2))+w_de_y(k);
        w_de_w(k)=abs(pred9(3)-gt(3))+w_de_w(k);
        w_de_h(k)=abs(pred9(4)-gt(4))+w_de_h(k);

        excel_codination = sprintf('%s%d:%s%d','J',(k-1)*4+2,'J',k*4+1);
        xlswrite(excle_predect,[pred9(1);pred9(2);pred9(3);pred9(4)],'sheet1',excel_codination);
    end
    for k=(epoch_num*0.9+1):epoch_num
        gt_tblr=to_tblr(gt);
        pred_tblr=to_tblr(pred9);
        IO=iou(pred_tblr,gt_tblr);
        dwiou_de=dWIOU_de(pred9,gt);
        pred9(1)=pred9(1)+learning_rate*0.02*(2-IO)*dwiou_de.dx;
        pred9(2)=pred9(2)+learning_rate*0.02*(2-IO)*dwiou_de.dy;
        pred9(3)=pred9(3)+learning_rate*0.02*(2-IO)*dwiou_de.dw;
        pred9(4)=pred9(4)+learning_rate*0.02*(2-IO)*dwiou_de.dh;
        a(k,2:5)=pred9;
        loss9=abs(a(k,2:5)-gt(1:4))+loss9;
        w_de_x(k)=abs(pred9(1)-gt(1))+w_de_x(k);
        w_de_y(k)=abs(pred9(2)-gt(2))+w_de_y(k);
        w_de_w(k)=abs(pred9(3)-gt(3))+w_de_w(k);
        w_de_h(k)=abs(pred9(4)-gt(4))+w_de_h(k);

        excel_codination = sprintf('%s%d:%s%d','J',(k-1)*4+2,'J',k*4+1);
        xlswrite(excle_predect,[pred9(1);pred9(2);pred9(3);pred9(4)],'sheet1',excel_codination);
    end
    final_error_wiou_de=abs(pred9(1)-gt(1))+abs(pred9(2)-gt(2))+abs(pred9(3)-gt(3))+abs(pred9(4)-gt(4));
    wiou_de0=loss9(1)+loss9(2)+loss9(3)+loss9(4);
    WIoU_de_Loss=wiou_de0;

    fprintf('Complete the regression of wiou_de\n');
    
    
    iii=i_x+i_y+i_w+i_h;
    ggg=g_x+g_y+g_w+g_h;
    ddd=d_x+d_y+d_w+d_h;
    ccc=c_x+c_y+c_w+c_h;
    eee=e_x+e_y+e_w+e_h;
    ddd_de=d_de_x+d_de_y+d_de_w+d_de_h;
    eee_de=e_de_x+e_de_y+e_de_w+e_de_h;
    www=w_x+w_y+w_w+w_h;
    www_de=w_de_x+w_de_y+w_de_w+w_de_h;
    
    % Save the error of bounding box regression
    excel_codination = sprintf('%s%d:%s%d','B',2,'B',epoch_num+1);
    xlswrite(excle_iou,iii,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','C',2,'C',epoch_num+1);
    xlswrite(excle_iou,ggg,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','D',2,'D',epoch_num+1);
    xlswrite(excle_iou,ddd,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','E',2,'E',epoch_num+1);
    xlswrite(excle_iou,ccc,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','F',2,'F',epoch_num+1);
    xlswrite(excle_iou,eee,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','G',2,'G',epoch_num+1);
    xlswrite(excle_iou,ddd_de,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','H',2,'H',epoch_num+1);
    xlswrite(excle_iou,eee_de,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','I',2,'I',epoch_num+1);
    xlswrite(excle_iou,www,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','J',2,'J',epoch_num+1);
    xlswrite(excle_iou,www_de,'sheet1',excel_codination);
    

    figure,plot(iii,'LineWidth',2);hold on
    plot(ggg,'LineWidth',2);hold on
    plot(ddd,'LineWidth',2);hold on
    plot(ccc,'LineWidth',2);hold on
    plot(eee,'LineWidth',2);hold on
    plot(www,'LineWidth',2);hold on
    plot(ddd_de,'LineWidth',2);hold on
    plot(eee_de,'color',getColor(5,10),'LineWidth',2);hold on
    plot(www_de,'color',getColor(10,10),'LineWidth',2),legend('IoU','GIoU','DIoU','CIoU','EIoU','WIoU','DIoU-de','EIoU-de','WIoU-de'),xlabel('Iteration'),ylabel('error');
    
    % plot boxes-------------------------------------------------------------
    % Read bounding box information
    gt_box = xlsread(excle_predect,'sheet1','K2:K5');
    initial_box = xlsread(excle_predect,'sheet1','L2:L5');

    epoch_codination_low = (epoch_count-1)*4+2;
    epoch_codination_high = epoch_count*4+1;
    iou_cod = sprintf('%s%d:%s%d','B',epoch_codination_low,'B',epoch_codination_high);
    iou_box = xlsread(excle_predect,'sheet1',iou_cod);
    giou_cod = sprintf('%s%d:%s%d','C',epoch_codination_low,'C',epoch_codination_high);
    giou_box = xlsread(excle_predect,'sheet1',giou_cod);
    diou_cod = sprintf('%s%d:%s%d','D',epoch_codination_low,'D',epoch_codination_high);
    diou_box = xlsread(excle_predect,'sheet1',diou_cod);
    ciou_cod = sprintf('%s%d:%s%d','E',epoch_codination_low,'E',epoch_codination_high);
    ciou_box = xlsread(excle_predect,'sheet1',ciou_cod);
    eiou_cod = sprintf('%s%d:%s%d','F',epoch_codination_low,'F',epoch_codination_high);
    eiou_box = xlsread(excle_predect,'sheet1',eiou_cod);
    diou_de_cod = sprintf('%s%d:%s%d','G',epoch_codination_low,'G',epoch_codination_high);
    diou_de_box = xlsread(excle_predect,'sheet1',diou_de_cod);
    eiou_de_cod = sprintf('%s%d:%s%d','H',epoch_codination_low,'H',epoch_codination_high);
    eiou_de_box = xlsread(excle_predect,'sheet1',eiou_de_cod);
    wiou_cod = sprintf('%s%d:%s%d','I',epoch_codination_low,'I',epoch_codination_high);
    wiou_box = xlsread(excle_predect,'sheet1',wiou_cod);
    wiou_de_cod = sprintf('%s%d:%s%d','J',epoch_codination_low,'J',epoch_codination_high);
    wiou_de_box = xlsread(excle_predect,'sheet1',wiou_de_cod);


    gt_box=to_xyxy(gt_box);
    initial_box=to_xyxy(initial_box);
    iou_box=to_xyxy(iou_box);
    giou_box=to_xyxy(giou_box);
    diou_box=to_xyxy(diou_box);
    ciou_box=to_xyxy(ciou_box);
    eiou_box=to_xyxy(eiou_box);
    diou_de_box=to_xyxy(diou_de_box);
    eiou_de_box=to_xyxy(eiou_de_box);
    wiou_box=to_xyxy(wiou_box);
    wiou_de_box=to_xyxy(wiou_de_box);


    % Draw a bounding box for a certain eopch
    figure,plot([iou_box.x1,iou_box.x2,iou_box.x4,iou_box.x3,iou_box.x1],[iou_box.y1,iou_box.y2,iou_box.y4,iou_box.y3,iou_box.y1],'LineWidth',2);hold on
    plot([giou_box.x1,giou_box.x2,giou_box.x4,giou_box.x3,giou_box.x1],[giou_box.y1,giou_box.y2,giou_box.y4,giou_box.y3,giou_box.y1],'LineWidth',2);hold on
    plot([diou_box.x1,diou_box.x2,diou_box.x4,diou_box.x3,diou_box.x1],[diou_box.y1,diou_box.y2,diou_box.y4,diou_box.y3,diou_box.y1],'LineWidth',2);hold on
    plot([ciou_box.x1,ciou_box.x2,ciou_box.x4,ciou_box.x3,ciou_box.x1],[ciou_box.y1,ciou_box.y2,ciou_box.y4,ciou_box.y3,ciou_box.y1],'LineWidth',2);hold on
    plot([eiou_box.x1,eiou_box.x2,eiou_box.x4,eiou_box.x3,eiou_box.x1],[eiou_box.y1,eiou_box.y2,eiou_box.y4,eiou_box.y3,eiou_box.y1],'LineWidth',2);hold on
    plot([wiou_box.x1,wiou_box.x2,wiou_box.x4,wiou_box.x3,wiou_box.x1],[wiou_box.y1,wiou_box.y2,wiou_box.y4,wiou_box.y3,wiou_box.y1],'LineWidth',2);hold on
    plot([diou_de_box.x1,diou_de_box.x2,diou_de_box.x4,diou_de_box.x3,diou_de_box.x1],[diou_de_box.y1,diou_de_box.y2,diou_de_box.y4,diou_de_box.y3,diou_de_box.y1],'LineWidth',2);hold on
    plot([eiou_de_box.x1,eiou_de_box.x2,eiou_de_box.x4,eiou_de_box.x3,eiou_de_box.x1],[eiou_de_box.y1,eiou_de_box.y2,eiou_de_box.y4,eiou_de_box.y3,eiou_de_box.y1],'color',getColor(5,10),'LineWidth',2);hold on
    plot([wiou_de_box.x1,wiou_de_box.x2,wiou_de_box.x4,wiou_de_box.x3,wiou_de_box.x1],[wiou_de_box.y1,wiou_de_box.y2,wiou_de_box.y4,wiou_de_box.y3,wiou_de_box.y1],'color',getColor(10,10),'LineWidth',2);hold on
    plot([gt_box.x1,gt_box.x2,gt_box.x4,gt_box.x3,gt_box.x1],[gt_box.y1,gt_box.y2,gt_box.y4,gt_box.y3,gt_box.y1],'--','LineWidth',3);hold on
    plot([initial_box.x1,initial_box.x2,initial_box.x4,initial_box.x3,initial_box.x1],[initial_box.y1,initial_box.y2,initial_box.y4,initial_box.y3,initial_box.y1],'--','LineWidth',3),legend('IoU','GIoU','DIoU','CIoU','EIoU','WIoU','DIoU-de','EIoU-de','WIoU-de','GT','Initial_Pre'),xlabel('X'),ylabel('Y');      %plot regression error sum curve
    fprintf('finish...\n');
end

%--------------------------the following is to redraw from previous results----------------------------%
if is_regresion==0
    
    fprintf('Processing regresion_process.m ...\n');
    
    excel_codination = sprintf('%s%d:%s%d','B',2,'B',epoch_num+1);
    iii = xlsread(excle_iou,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','C',2,'C',epoch_num+1);
    ggg = xlsread(excle_iou,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','D',2,'D',epoch_num+1);
    ddd = xlsread(excle_iou,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','E',2,'E',epoch_num+1);
    ccc = xlsread(excle_iou,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','F',2,'F',epoch_num+1);
    eee = xlsread(excle_iou,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','G',2,'G',epoch_num+1);
    ddd_de = xlsread(excle_iou,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','H',2,'H',epoch_num+1);
    eee_de = xlsread(excle_iou,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','I',2,'I',epoch_num+1);
    www = xlsread(excle_iou,'sheet1',excel_codination);
    excel_codination = sprintf('%s%d:%s%d','J',2,'J',epoch_num+1);
    www_de = xlsread(excle_iou,'sheet1',excel_codination);

    
    figure,plot(iii,'LineWidth',2);hold on
    plot(ggg,'LineWidth',2);hold on
    plot(ddd,'LineWidth',2);hold on
    plot(ccc,'LineWidth',2);hold on
    plot(eee,'LineWidth',2);hold on
    plot(www,'LineWidth',2);hold on
    plot(ddd_de,'LineWidth',2);hold on
    plot(eee_de,'color',getColor(5,10),'LineWidth',2);hold on
    plot(www_de,'color',getColor(10,10),'LineWidth',2),legend('IoU','GIoU','DIoU','CIoU','EIoU','WIoU','DIoU-de','EIoU-de','WIoU-de'),xlabel('Iteration'),ylabel('error'); 
    
    % ---------------- plot boxes ---------------- %
    % Read bounding box information
    gt_box = xlsread(excle_predect,'sheet1','K2:K5');
    initial_box = xlsread(excle_predect,'sheet1','L2:L5');

    epoch_codination_low = (epoch_count-1)*4+2;
    epoch_codination_high = epoch_count*4+1;
    iou_cod = sprintf('%s%d:%s%d','B',epoch_codination_low,'B',epoch_codination_high);
    iou_box = xlsread(excle_predect,'sheet1',iou_cod);
    giou_cod = sprintf('%s%d:%s%d','C',epoch_codination_low,'C',epoch_codination_high);
    giou_box = xlsread(excle_predect,'sheet1',giou_cod);
    diou_cod = sprintf('%s%d:%s%d','D',epoch_codination_low,'D',epoch_codination_high);
    diou_box = xlsread(excle_predect,'sheet1',diou_cod);
    ciou_cod = sprintf('%s%d:%s%d','E',epoch_codination_low,'E',epoch_codination_high);
    ciou_box = xlsread(excle_predect,'sheet1',ciou_cod);
    eiou_cod = sprintf('%s%d:%s%d','F',epoch_codination_low,'F',epoch_codination_high);
    eiou_box = xlsread(excle_predect,'sheet1',eiou_cod);
    diou_de_cod = sprintf('%s%d:%s%d','G',epoch_codination_low,'G',epoch_codination_high);
    diou_de_box = xlsread(excle_predect,'sheet1',diou_de_cod);
    eiou_de_cod = sprintf('%s%d:%s%d','H',epoch_codination_low,'H',epoch_codination_high);
    eiou_de_box = xlsread(excle_predect,'sheet1',eiou_de_cod);
    wiou_cod = sprintf('%s%d:%s%d','I',epoch_codination_low,'I',epoch_codination_high);
    wiou_box = xlsread(excle_predect,'sheet1',wiou_cod);
    wiou_de_cod = sprintf('%s%d:%s%d','J',epoch_codination_low,'J',epoch_codination_high);
    wiou_de_box = xlsread(excle_predect,'sheet1',wiou_de_cod);


    gt_box=to_xyxy(gt_box);
    initial_box=to_xyxy(initial_box);
    iou_box=to_xyxy(iou_box);
    giou_box=to_xyxy(giou_box);
    diou_box=to_xyxy(diou_box);
    ciou_box=to_xyxy(ciou_box);
    eiou_box=to_xyxy(eiou_box);
    diou_de_box=to_xyxy(diou_de_box);
    eiou_de_box=to_xyxy(eiou_de_box);
    wiou_box=to_xyxy(wiou_box);
    wiou_de_box=to_xyxy(wiou_de_box);


    % Draw a bounding box for a certain eopch
    figure,plot([iou_box.x1,iou_box.x2,iou_box.x4,iou_box.x3,iou_box.x1],[iou_box.y1,iou_box.y2,iou_box.y4,iou_box.y3,iou_box.y1],'LineWidth',2);hold on
    plot([giou_box.x1,giou_box.x2,giou_box.x4,giou_box.x3,giou_box.x1],[giou_box.y1,giou_box.y2,giou_box.y4,giou_box.y3,giou_box.y1],'LineWidth',2);hold on
    plot([diou_box.x1,diou_box.x2,diou_box.x4,diou_box.x3,diou_box.x1],[diou_box.y1,diou_box.y2,diou_box.y4,diou_box.y3,diou_box.y1],'LineWidth',2);hold on
    plot([ciou_box.x1,ciou_box.x2,ciou_box.x4,ciou_box.x3,ciou_box.x1],[ciou_box.y1,ciou_box.y2,ciou_box.y4,ciou_box.y3,ciou_box.y1],'LineWidth',2);hold on
    plot([eiou_box.x1,eiou_box.x2,eiou_box.x4,eiou_box.x3,eiou_box.x1],[eiou_box.y1,eiou_box.y2,eiou_box.y4,eiou_box.y3,eiou_box.y1],'LineWidth',2);hold on
    plot([wiou_box.x1,wiou_box.x2,wiou_box.x4,wiou_box.x3,wiou_box.x1],[wiou_box.y1,wiou_box.y2,wiou_box.y4,wiou_box.y3,wiou_box.y1],'LineWidth',2);hold on
    plot([diou_de_box.x1,diou_de_box.x2,diou_de_box.x4,diou_de_box.x3,diou_de_box.x1],[diou_de_box.y1,diou_de_box.y2,diou_de_box.y4,diou_de_box.y3,diou_de_box.y1],'LineWidth',2);hold on
    plot([eiou_de_box.x1,eiou_de_box.x2,eiou_de_box.x4,eiou_de_box.x3,eiou_de_box.x1],[eiou_de_box.y1,eiou_de_box.y2,eiou_de_box.y4,eiou_de_box.y3,eiou_de_box.y1],'color',getColor(5,10),'LineWidth',2);hold on
    plot([wiou_de_box.x1,wiou_de_box.x2,wiou_de_box.x4,wiou_de_box.x3,wiou_de_box.x1],[wiou_de_box.y1,wiou_de_box.y2,wiou_de_box.y4,wiou_de_box.y3,wiou_de_box.y1],'color',getColor(10,10),'LineWidth',2);hold on
    plot([gt_box.x1,gt_box.x2,gt_box.x4,gt_box.x3,gt_box.x1],[gt_box.y1,gt_box.y2,gt_box.y4,gt_box.y3,gt_box.y1],'--','LineWidth',3);hold on
    plot([initial_box.x1,initial_box.x2,initial_box.x4,initial_box.x3,initial_box.x1],[initial_box.y1,initial_box.y2,initial_box.y4,initial_box.y3,initial_box.y1],'--','LineWidth',3),legend('IoU','GIoU','DIoU','CIoU','EIoU','WIoU','DIoU-de','EIoU-de','WIoU-de','GT','Initial_Pre'),xlabel('X'),ylabel('Y');      %plot regression error sum curve
    fprintf('finish...\n');
end