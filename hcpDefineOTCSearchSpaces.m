
% Define LOTC/VOTC search spaces based on multimodal parcellation

MMPpath = '/mnt/sml_share/HCP/derivatives/fpp/sub-hcp100206/anat/space-fsLR_den-32k_desc-MMP_dseg.dlabel.nii';
LVOTCkeys = [343,187,198];
RVOTCkeys = [163,7,18];%VVC,V8,FFC
LLOTCkeys = [202,200,201,339,336,203];%PIT, LO1, LO2, LO3, V4t, and MT
RLOTCkeys = [22,20,21,159,156,23];
all_keys = {LVOTCkeys,RVOTCkeys,LLOTCkeys,RLOTCkeys};
all_names = {'LVOTC','RVOTC','LLOTC','RLOTC'};
for k = 1:numel(all_keys)
   grouppath = '/mnt/sml_share/HCP/derivatives/fpp/group';
   testoutPath = [grouppath '/MMPParcels/space-fsLR_den-32k_desc-mmp' all_names{k} '_mask.dscalar.nii'];
   disp(all_names{k})
   fpp.util.label2ROI(MMPpath,all_keys{k},testoutPath);
end