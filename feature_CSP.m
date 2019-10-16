function [SpatialFilter,A]=feature_CSP(EEGDATA,LABELS,number)

visual=0;
m=round(number/2);              %选取的最大、最小特征值的个数

row=size(EEGDATA,1);
% for i=1:size(EEGDATA,3)    
%      EEGDATA(:,:,i)=detrend(EEGDATA(:,:,i)')';    
%      EEGDATA(:,:,i)=EEGDATA(:,:,i)-mean(EEGDATA(:,:,i),2)*ones(1,size(EEGDATA(:,:,i),2));
% end
cl=zeros(size(EEGDATA,1)); cr=zeros(size(EEGDATA,1));

difflabel=diffnum(LABELS);
lindex=find(LABELS==difflabel(1));
rindex=find(LABELS==difflabel(2));
lnum=size(lindex,1); rnum=size(rindex,1);
for j=1:lnum
    tmp=EEGDATA(:,:,lindex(j))*EEGDATA(:,:,lindex(j))';
    cl=cl+ tmp./trace(tmp);    
end
for j=1:rnum
    tmp=EEGDATA(:,:,rindex(j))*EEGDATA(:,:,rindex(j))';
    cr=cr+ tmp./trace(tmp);  
end

cl=cl./lnum;
cr=cr./rnum;
cc=cl+cr;
[V,D] = eig(cc);

P=(sqrt(D^-1))*V';
sl=P*cl*P';
sr=P*cr*P';
[V,D] = eig(sl);


[V1,D1]=eig(sr);


%%%%%%%%%%%%%%%%%select larger and smaller eigvector for V or V1%%%%%%%%%
% feig=row-m+1; leig=m;
% [V,D]=selEigvector( V, D, feig,leig);
% [V1,D1]=selEigvector( V1, D1, feig,leig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%select the largest m eigvector from V and V1 %%%%%%%%%%%%%%%%%%%
% sort the D and V
[D,index]=sort(diag(D));
V2 = V(:,index(1:m));
% D=flipud(D);
index=flipud(index);
V=V(:,index);
% sort the D1 and V1
% [D1,index]=sort(diag(D1));
% D1=flipud(D1); index=flipud(index);
% V1=V1(:,index);
% find the  eigvector
V=V(:,1:m);
% V1=V1(:,1:m);

% VV=[V V1];
VV=[V V2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W=VV'*P;

SpatialFilter = W;

if(visual==1)
    CSPcom=zeros(size(W,1),size(EEGDATA,2),size(EEGDATA,3));
    for i=1:size(EEGDATA,3)
        CSPcom(:,:,i)=W*EEGDATA(:,:,i);
    end
    eegplot(CSPcom); title('CSP compenents');
end

% ====computer the features by spatial filter====
% eegFeatures=[];
% for i=1:size(EEGDATA,3)
%     FeaData=W*EEGDATA(:,:,i);
%     FeaData=diag(cov(FeaData'));
%     FeaData=FeaData./sum(FeaData);
%     FeaData=log(FeaData);
%     eegFeatures=[eegFeatures FeaData];
% end
%=====================================

A=pinv(W);

if (visual==1)
    if (size(A,1)==62)
        mytopoplot(A); title('topology of IC map');
    end
displot(EEGDATA',LABELS); title('Data distribution of CSP feature');
plotMI(LABELS,EEGDATA'); title('MI of CSP components');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% function [EE,DD]= selEigvector( E, D, firstEig,lastEig)
% oldDimension=size(D,1);
% % Sort the eigenvalues - decending.
% eigenvalues = flipud(sort(diag(D)));
% % Drop the smaller eigenvalues
% if lastEig < oldDimension
%   lowerLimitValue = (eigenvalues(lastEig) + eigenvalues(lastEig + 1)) / 2;
% else
%   lowerLimitValue = eigenvalues(oldDimension) - 1;
% end
% lowerColumns = diag(D) > lowerLimitValue;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Drop the larger eigenvalues
% if firstEig > 1
%   higherLimitValue = (eigenvalues(firstEig - 1) + eigenvalues(firstEig)) / 2;
% else
%   higherLimitValue = eigenvalues(1) + 1;
% end
% higherColumns = diag(D) < higherLimitValue;
% 
% % Combine the results from above
% selectedColumns = lowerColumns | higherColumns;              %modify by zqb   lowerColumns & higherColumns
% EE = selcol(E, selectedColumns);
% DD = selcol(selcol(D, selectedColumns)', selectedColumns);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function newMatrix = selcol(oldMatrix, maskVector);
% 
% % newMatrix = selcol(oldMatrix, maskVector);
% %
% % Selects the columns of the matrix that marked by one in the given vector.
% % The maskVector is a column vector.
% 
% % 15.3.1998
% 
% if size(maskVector, 1) ~= size(oldMatrix, 2),
%   error ('The mask vector and matrix are of uncompatible size.');
% end
% 
% numTaken = 0;
% 
% for i = 1 : size (maskVector, 1),
%   if maskVector(i, 1) == 1,
%     takingMask(1, numTaken + 1) = i;
%     numTaken = numTaken + 1;
%   end
% end
% 
% newMatrix = oldMatrix(:, takingMask);


