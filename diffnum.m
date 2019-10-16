% diffnum() -  Eliminate the same data in vector
% Usage:
%    >> diffnum(s)
%
% Inputs:
%   s   - input data vector 
%   
% Outputs:%   
%   diffnum  - different data of vector

% Author: Qibin Zhao 2006/09/27
%
function [diffnum]=diffnum(s)
diffnum=[];
diffnum=s(1);
samenum=[];
for i=1:length(s)     
    if all(diffnum~=s(i))
        diffnum=[diffnum;s(i)];
    end
end
% diffnum = sort(diffnum);