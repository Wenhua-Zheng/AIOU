% Convert xywh to tblr
function s=to_tblr(X)
x=X(1);
y=X(2);
w=X(3);
h=X(4);
s.t=y-h/2;
s.b=y+h/2;
s.l=x-w/2;
s.r=x+w/2;