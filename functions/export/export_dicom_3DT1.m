function export_dicom_3DT1(directory,m0map,t1map,parameters,tag)



% Phase orientation orientation correction
if isfield(parameters, 'PHASE_ORIENTATION')
    if parameters.PHASE_ORIENTATION == 1
        t1map = permute(t1map,[2 3 4 1]);
        t1map = permute(rot90(permute(t1map,[2 1 3 4]),1),[2 1 3 4]);
        t1map = permute(t1map,[4 1 2 3]);
        
        m0map = permute(m0map,[2 3 4 1]);
        m0map = permute(rot90(permute(m0map,[2 1 3 4]),1),[2 1 3 4]);
        m0map = permute(m0map,[4 1 2 3]);
    end
end


% Size of the M0 and T1 maps
[nr_frames,dimx,dimy,dimz] = size(t1map);



% ------------------------
% Export T1 map images
% ------------------------


% Create folder if not exist, and clear
folder_name = [directory,[filesep,'T1map-DICOM-',tag]];
if (~exist(folder_name, 'dir')); mkdir(folder_name); end
delete([folder_name,filesep,'*']);



% Export

dcmid = dicomuid;   % unique identifier
dcmid = dcmid(1:50);

cnt = 1;

for j = 1:nr_frames             % for all frames / temporal positions
    
    for i = 1:dimz              % for all slices
        
        % Generate dicom header from scratch
        dcm_header = generate_dicomheader_3DT1(parameters,dimx,dimy,i,j,dcmid,cnt);
        dcm_header.ProtocolName = 'T1-map';
        dcm_header.SequenceName = 'T1-map';
        dcm_header.EchoTime = 0;
        fn = ['0000',num2str(cnt)];
        fn = fn(size(fn,2)-4:size(fn,2));
        
        % Dicom filename
        fname = [directory,filesep,'T1map-DICOM-',tag,filesep,fn,'.dcm'];
        
        % T1 images
        image = rot90(squeeze(cast(round(t1map(j,:,:,i)),'uint16')));
        
        % Write the dicom file
        dicomwrite(image, fname, dcm_header);
        
        cnt = cnt + 1;
        
    end
    
end




% ------------------------
% Export M0 map images
% ------------------------

% Create folder if not exist, and clear
folder_name = [directory,[filesep,'M0map-DICOM-',tag]];
if (~exist(folder_name, 'dir')); mkdir(folder_name); end
delete([folder_name,filesep,'*']);

% Scale
while max(m0map(:))>65535
   m0map = m0map/2; 
end

% Export

dcmid = dicomuid;   % unique identifier
dcmid = dcmid(1:50);

cnt = 1;

for j = 1:nr_frames             % for all frames / temporal positions
    
    for i = 1:dimz              % for all slices
        
        % Generate dicom header from scratch
        dcm_header = generate_dicomheader_3DT1(parameters,dimx,dimy,i,j,dcmid,cnt);
        dcm_header.ProtocolName = 'M0-map';
        dcm_header.SequenceName = 'M0-map';
        dcm_header.EchoTime = 1;
        fn = ['0000',num2str(cnt)];
        fn = fn(size(fn,2)-4:size(fn,2));
        
        % Dicom filename
        fname = [directory,filesep,'M0map-DICOM-',tag,filesep,fn,'.dcm'];
        
        % M0 images
        image = rot90(squeeze(cast(round(m0map(j,:,:,i)),'uint16')));
        
        % Write the dicom file
        dicomwrite(image, fname, dcm_header);
        
        cnt = cnt + 1;
        
    end
    
end


end