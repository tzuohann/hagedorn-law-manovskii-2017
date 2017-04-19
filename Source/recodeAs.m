function In =  recodeAs(In,Recode)
  %In =  recodeAs(In,Recode)
  %Takes In, and spits back the recoded.
  In( In~= 0 & ~isnan(In) ) = Recode(In( In~= 0 & ~isnan(In) ));
end