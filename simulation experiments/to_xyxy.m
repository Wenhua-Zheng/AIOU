function s=to_xyxy(X)
x=X(1);
y=X(2);
w=X(3);
h=X(4);
s.x1=x-(w/2);
s.y1=y-(h/2);
s.x2=x+(w/2);
s.y2=y-(h/2);
s.x3=x-(w/2);
s.y3=y+(h/2);
s.x4=x+(w/2);
s.y4=y+(h/2);