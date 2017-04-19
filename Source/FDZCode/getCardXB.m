%Build design matrix for match effect or two-way fixed effect regression
function Z = getCardXB(inputData)
  year   = inputData(:,1);
  birth  = inputData(:,2);
  educ   = inputData(:,3);
  %Build time trends
  yrmin=min(year); yrmax=max(year);
  educmin=min(educ); educmax=max(educ);
  
  %Educ0 - 1993 1994 ... Educ1 - 1993 1994 ...
  R=sparse(1:size(year,1),(year-yrmin+1)+(yrmax-yrmin+1)*(educ - 1),1); %year effects by education
  idx=1+(yrmax-yrmin+1)*((1:max(educ)) - 1);
  R(:,idx)=[]; %drop first year effect in each education group
  
  E=sparse(1:size(year,1),educ,1);
  age=year-birth;
  age=(age-40)/40; %rescale to avoid big numbers
  A=[bsxfun(@times,E,age.^2),bsxfun(@times,E,age.^3)]; %age cubic by education
  
  Z=[R,A];
end

