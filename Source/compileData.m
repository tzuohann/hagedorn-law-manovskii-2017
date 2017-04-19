function compileData(Folder)
  TempTemp = pwd;
  cd(Folder)
  if exist('Data.mat','file')
    delete Data.mat
  end
  cd(TempTemp); clear TempTemp
  Dirs = dir([Folder,'\*.mat']);
  
  numelLim   = 1;
  
  for i1 = 1:numel(Dirs);
    A = Dirs(i1).name;
    disp(A)
    
    underScoreLoc = find(A == '_');
    SchemeNameStr   = A(1:underScoreLoc(1)-1);
    ProdNameStr   = A(underScoreLoc(1) + 1:underScoreLoc(2)-1);
    
    if strcmp(SchemeNameStr,'benchmark')
      load([Folder,'\',A],'C','P','RD','V','SimO','S','M');
    else
      load([Folder,'\',A],'C','P','RD','V','SimO','S');
    end
    %PAM NAM OR NOT
    switch lower(ProdNameStr)
      case {'pam'}
        ProdName(i1,:) = 1;
      case {'nam'}
        ProdName(i1,:) = 2;
      case {'not'}
        ProdName(i1,:) = 3;
    end
    
    switch lower(SchemeNameStr)
      case {'benchmark'}
        SchemeName(i1,:) = 1;
      case {'smallfirms'}
        SchemeName(i1,:) = 2;
      case {'highbeta'}
        SchemeName(i1,:) = 3;
      case {'shortsample'}
        SchemeName(i1,:) = 4;
      case {'matchquality'}
        SchemeName(i1,:) = 5;
      case {'ojs'}
        SchemeName(i1,:) = 6;
    end
    
    if strcmp(SchemeNameStr,'benchmark')
      %% Expand M
      StructName = M;
      Head       = 'M';
      for ip = fieldnames(StructName)'
        ipc   = char(ip);
        Var  = getfield(StructName,ipc);
        if strcmp(numelLim,'all')
          eval([Head,'_',ipc,'(i1,:)=Var;'])
        elseif numel(Var) <= numelLim
          eval([Head,'_',ipc,'(i1,:)=Var;'])
        end
      end
    end
    
    %% Expand P
    StructName = P;
    Head       = 'P';
    for ip = fieldnames(StructName)'
      ipc   = char(ip);
      Var  = getfield(StructName,ipc);
      if strcmp(numelLim,'all')
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      elseif numel(Var) <= numelLim
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      end
    end
    
    %% Expand C
    StructName = C;
    Head       = 'C';
    for ip = fieldnames(StructName)'
      ipc   = char(ip);
      Var  = getfield(StructName,ipc);
      if strcmp(numelLim,'all')
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      elseif numel(Var) <= numelLim
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      end
    end
    
    %% Expand SimO
    StructName = SimO;
    Head       = 'SimO';
    for ip = fieldnames(StructName)'
      ipc   = char(ip);
      Var  = getfield(StructName,ipc);
      if strcmp(numelLim,'all')
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      elseif numel(Var) <= numelLim
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      end
    end
    
    %% Expand RD.SP
    StructName = RD.SP;
    Head       = 'RDSP';
    for ip = fieldnames(StructName)'
      ipc   = char(ip);
      Var  = getfield(StructName,ipc);
      if strcmp(numelLim,'all')
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      elseif numel(Var) <= numelLim
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      end
    end
    
    %% Expand RD.Y
    StructName = RD.Y;
    Head       = 'RDY';
    for ip = fieldnames(StructName)'
      ipc   = char(ip);
      Var  = getfield(StructName,ipc);
      if strcmp(numelLim,'all')
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      elseif numel(Var) <= numelLim
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      end
    end
    
    %% Expand RD.FS
    StructName = RD.FS;
    Head       = 'RDFS';
    for ip = fieldnames(StructName)'
      ipc   = char(ip);
      Var  = getfield(StructName,ipc);
      if strcmp(numelLim,'all')
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      elseif numel(Var) <= numelLim
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      end
    end
    
    %% Expand RD.I
    StructName = RD.I;
    Head       = 'RDI';
    for ip = fieldnames(StructName)'
      ipc   = char(ip);
      Var  = getfield(StructName,ipc);
      if strcmp(numelLim,'all')
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      elseif numel(Var) <= numelLim
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      end
    end
    
    %% Expand RD.AKM
    StructName = RD.AKM;
    Head       = 'RDAKM';
    for ip = fieldnames(StructName)'
      ipc   = char(ip);
      Var  = getfield(StructName,ipc);
      if strcmp(numelLim,'all')
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      elseif numel(Var) <= numelLim
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      end
    end
    
    %% Expand S
    StructName = S;
    Head       = 'S';
    for ip = fieldnames(StructName)'
      ipc   = char(ip);
      Var  = getfield(StructName,ipc);
      if strcmp(numelLim,'all')
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      elseif numel(Var) <= 4
        eval([Head,'_',ipc,'(i1,:)=Var;'])
      end
    end
    
  end
  Temp = pwd;
  cd(Folder)
  clear A Dirs M P RD SimO TempTemp US i1 Folder Var ipc numelLim ip C StructName Sim
  save('Data.mat', '-v7.3')
  cd(Temp)
end


