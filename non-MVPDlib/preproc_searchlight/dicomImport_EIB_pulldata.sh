projectdir="/mindhive/gablab/u/daeda/analyses/EIB/EIB_data/"
remotedir="/mindhive/saxelab3/moveSaxelab2/EIB/"

for i in 10 16 17 18 21 22 23 25 26 27 38 39 40 41 42 28 29 31 32 33 34 36 57 63 64 66 67 68 69 70
do
        mkdir ${projectdir}SAX_EIB_${i}
        mkdir ${projectdir}SAX_EIB_${i}/report
        cmd1="${remotedir}SAX_EIB_${i}/dicom ${projectdir}SAX_EIB_${i}"
        cmd2="${remotedir}SAX_EIB_${i}/report/scan_info ${projectdir}SAX_EIB_${i}/report"

        cp -r $cmd1
        cp $cmd2

        echo "SAX_EIB_${i}" >> ${projectdir}transfered.txt
done

cp /mindhive/saxelab3/moveSaxelab2/EIB/EIB_subject_taskruns.mat ${projectdir}
