function globalSignal = loadDenoise_globalSignal(parameters, subject, volumes2)

globalSignal = mean(volumes2,1);
if size(globalSignal,2)>1
    globalSignal = globalSignal';
end
