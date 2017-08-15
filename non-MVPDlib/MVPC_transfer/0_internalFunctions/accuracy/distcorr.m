function r = distcorr(X,Y)

if (size(X,1)~=size(Y,1))
    warning('The two matrices must have the same number of rows');
    return
end

n = size(X,1);
for k=1:n
    for l=1:n
        xd = (X(k,:)-X(l,:));
        akl(k,l) = xd*xd';
        yd = (Y(k,:)-Y(l,:));
        bkl(k,l) = yd*yd';
    end
end
ak = mean(akl,2);
al = mean(akl,1);
a = mean(al);
bk = mean(bkl,2);
bl = mean(bkl,1);
b = mean(bl);
sum_r_a=0;
sum_r_b=0;
sum_r_ab=0;
for k=1:n
    for l=1:n
        sum_r_a = sum_r_a+(akl(k,l)-ak(k)-al(l)+a)^2;
        sum_r_b = sum_r_b+(bkl(k,l)-bk(k)-bl(l)+b)^2;        
        sum_r_ab = sum_r_ab+(akl(k,l)-ak(k)-al(l)+a)*(bkl(k,l)-bk(k)-bl(l)+b);
    end
end

r_num = sum_r_ab/(n^2);
if sum_r_a*sum_r_b>0
    r_den = sqrt(sum_r_a*sum_r_b)/(n^2);
    r = r_num/r_den;
else
    r = 0;
end

