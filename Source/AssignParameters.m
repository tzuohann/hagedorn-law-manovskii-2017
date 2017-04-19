function [P] = AssignParameters(C,V,S,iout,iprod)
  %Forms P and C for this particular paremterization.
  %See user guide/data dictionary for more information.
  %Get clock and form filename for saving

  %This takes the correct combination of values from V to compute.
  P        = PAssign(V,S,iout);
  
  switch(iprod)
    case {1}
      ProdFnName = 'pam';
    case {2}
      ProdFnName = 'nam';
    case {3}
      ProdFnName = 'not';
    otherwise
      error('Invalid Production Function')
  end
  
  P.FName = strcat([S.Scheme,'_',ProdFnName,'_',num2str(iout,'%06i\n'),'_',datestr(clock,'yymmddHHMMSS')]);
  P.ProdFn = V.ProdFn.(ProdFnName);
  
  %Record the iteration
  P.IOut = iout;
  display(strcat(['IOut = ',num2str(iout)]))
  
  %Grab the meeting function
  P.MeetFn = '@(v,s,Kkappa,NnuS,NnuV) min(min(v,Kkappa * s.^NnuS * v.^NnuV),s)';

end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function P = PAssign(V,S,iout) %#ok<*INUSD>
  %Assign to P a particular set from V
  V = rmfield(V,{'ProdFn'});
  Temp = fieldnames(V);
  for i1 = 1:size(Temp,1)
    eval(strcat(['P.',Temp{i1},' = V.',Temp{i1},'(S.Mix(iout,',num2str(i1),'),:);']))
  end
end
