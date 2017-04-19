capture confirm file "$ROOTDIR\log\done.done"
 while _rc {
	 sleep 120000
	 capture confirm file "$ROOTDIR\log\done.done"
	 if _rc {
		disp "shell command running: $cmdrunning"
	 }
	 else {
		erase "$ROOTDIR\log\done.done"
	 }
 }
