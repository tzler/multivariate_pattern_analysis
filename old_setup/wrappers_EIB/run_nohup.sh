# ps -ef | grep daeda
# kill -9 PID
nohup matlab -nodesktop -nosplash -r "try, run('wrapper_mvpc_EIB.m'), catch me, fprintf('%s / %s\n',me.identifier,me.message), end, exit" < /dev/null  > ../../nohup_EIB_mvpc_process.txt &