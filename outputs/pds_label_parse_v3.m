%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Name: pds_label_parse_v3.m
%
%Usage: [info] = pds_label_parse_v3(file,maxcnt,eof_name);
%
%Description: Program to read Cassini SAR PDS and ISIS image labels
%             (will also read most other PDS formats as well)
%
%Inputs:
%        file:     Name of PDS image, ISIS .cub file, or VICAR .VIC file
%
%        maxcnt:   Maximum number of lines read before leaving function
%                  (Defaults to 1000)
%
%        eof_name: String which indicates end of header portion of file
%                  (Defaults to END)
%
%Outputs:
%       info:  Structure array of string header values
%
%Function Calls:
%               vicar_label_parse (located within this m-file)
%
%Required Data Files:
%                    None
%
%
%Examples:
%        %%Read in a Band Sequential ISIS3 image header
%         %define a filename
%         filename = 't16_reproc1_corramb_bidr_s0nsqt_corr_crop_isis3.cub';
%         %read the entire file
%         info = pds_label_parse(filename);
%
%Change Log:
%           March 2007: Origin Version Created by Alex Hayes
%                       (hayes@gps.caltech.edu)
%           03/04/11:   Header added (Alex Hayes)
%           04/18/11:   Updated to work with ISIS3 formats (Alex Hayes)
%           04/03/12:   Incremented to version 3 after cleaning up 
%                       how output structures are defined.
%           04/12/13:   Small corrections for errors in some VIMS cubes
%                       regarding line demensions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [info] = pds_label_parse_v3(file,maxcount,maxcnt,eof_name);

%check for file existence
if ~exist(file,'file');
    disp('File Does Not Exist, Exiting...');
    value = -1;
    string = -1;
    return;
end;

%see if we have input a vicar file and, if so, use vicar label parse
file = strtrim(file);
if strcmp(lower(file(end-2:end)),'vic');
    disp('Detected VICAR File Format!');
    info = vicar_label_parse(file);
    return;
end;

%open the file
fid=fopen(file,'r');

%set up exist counter
if ~exist('maxcnt','var');
    maxcnt = 1000;
end;

%remove case sensativity of end of file name
if ~exist('eof_name','var') | isempty(eof_name);
    eof_name = 'END';
end;
eof_name = lower(eof_name);

%step through the file and get the label info
info.pds_label_parse_rundate = datestr(now);
tline='tempstart';
cnt = 0;
line_cnt = 0;
group_name = [];
object_name = [];
obj_cnt = 1;
grp_cnt = 1;
units_exist = 0;
skip_read = 0;

%keep stepping through the file until we encounter eof_name or maxcnt
while (~strcmp(eof_name,tline) & cnt < maxcnt);
    
    %we only care about headers lines with "=" in them
    eqpos = findstr('=',tline);
    
    %determine if the current line is distinguishing the start or
    %end of an object / group
    if length(tline) > 0 & ischar(tline);
        
        %see if a object is starting or ending on this line
        tline_temp = strrep(tline,' ','');
        if (numel(tline_temp) >= 7) & strcmp(tline_temp(1:7),'object=');
            %if (numel(tline) >= 8) & strcmp(lower(strtrim(tline(1:8))),'object =');
            
            %determine the group name and either append or create it
            object_temp = strrep(strtrim(tline(eqpos(1)+1:end)),' ','_');
            
            %see if the object name has already been used, and if so
            %increment until it is different
            increment = 0;
            object_temp0 = object_temp;
            inc_num = 2;
            if exist('object_names','var');
                for i=1:numel(object_names);
                    if strcmp(object_temp,object_names{i});
                        object_temp = [object_temp0 num2str(inc_num)];
                        inc_num = inc_num + 1;
                    end;
                end;
            end;
            object_names{obj_cnt} = object_temp;
            obj_cnt = obj_cnt+1;
            
            
            if ~isempty(object_name);
                object_name = [object_name '.' object_temp];
            else;
                object_name = object_temp;
            end;
            eqpos = [];
            
            %determine if an object is ending on this line
        elseif length(strfind(tline,'end_object')) > 0;
            eqpos = [];
            %if there are appended names, only kill the last one
            dos_pos = strfind(object_name,'.');
            if ~isempty(dos_pos);
                %disp(object_name)
                object_name = object_name(1:(dos_pos(end)-1));
                %disp(object_name)
            else;
                object_name = [];
            end;
            %since an object is ending, we can restart the repeat group
            %counter
            clear group_names
            grp_cnt = 1;
            
            if strcmp(tline(1),'^');
                eqpos = [];
            end;
            
            %see if a group is starting or ending on this line
        elseif (numel(tline_temp) >= 7) & strcmp(tline_temp(1:6),'group=');
            %elseif (numel(tline) >= 8) & strcmp(lower(strtrim(tline(1:8))),'group =');
            %elseif length(strfind(tline,'group =')) > 0;
            
            %determine the group name and either append or create it
            group_temp = strrep(strtrim(tline(eqpos(1)+1:end)),' ','_');
            
            %see if the group name has already been used in the current
            %object and, if so, increment until it is different
            increment = 0;
            group_temp0 = group_temp;
            inc_num = 2;
            if exist('group_names','var');
                for i=1:numel(group_names);
                    if strcmp(group_temp,group_names{i});
                        group_temp = [group_temp0 num2str(inc_num)];
                        inc_num = inc_num + 1;
                    end;
                end;
            end;
            group_names{grp_cnt} = group_temp;
            grp_cnt = grp_cnt+1;
            
            
            if ~isempty(group_name);
                group_name = [group_name '.' group_temp];
            else;
                group_name = group_temp;
            end;
            eqpos = [];
            
            %determine if a group is ending on this line
        elseif length(strfind(tline,'end_group')) > 0;
            eqpos = [];
            %if there are appended names, only kill the last one
            dos_pos = strfind(group_name,'.');
            if ~isempty(dos_pos);
                %disp(group_name);
                group_name = group_name(1:(dos_pos(end)-1));
                %disp(group_name);
            else;
                group_name = [];
            end;
            
            if strcmp(tline(1),'^');
                eqpos = [];
            end;
        end;
        
        %create a string determining the position in the output
        %structure
        if ~isempty(object_name) & ~isempty(group_name);
            eval_string = ['info.' object_name '.' group_name '.'];
        elseif ~isempty(object_name) & isempty(group_name);
            eval_string = ['info.' object_name '.'];
        elseif isempty(object_name) & ~isempty(group_name);
            eval_string = ['info.' group_name '.'];
        else;
            eval_string = ['info.'];
        end;
        
    end;
    
    % determine the keyword name and value
    if ~isempty(eqpos) > 0;
        %redefine skip_read (used later)
        skip_read = 0;
        
        %get the variable name
        value_name = lower(strtrim(tline(1:(eqpos-1))));
        value_name = strrep(value_name,' ','_');
       
        
        %remove any special characters (except handle carrots seperately)
        value_name_fix = fix(value_name);
        ind = find( value_name_fix == 94);
        if length(ind) > 0;
            value_name(ind) = 'c';
            value_name_fix = fix(value_name);
        end;
        ind = find( ((value_name_fix >= 97) & (value_name_fix <= 122)) | ...
                    ((value_name_fix >= 48) & (value_name_fix <= 57 )) );
        value_name = char(value_name_fix(ind));
        
        
        %get the string representing the variable value
        value      = strtrim(tline((eqpos+1):end));
        if  ~isempty(value) > 0;
            if strcmp(value(end),'-');
                tline2 = strtrim(lower(fgetl(fid)));
                tline2 = strrep(tline2,' ','');
                tline = [tline(1:end-1) tline2];
                value      = strtrim(tline((eqpos+1):end));
                disp('Combined Lines Early');
            end;
        end;
        
        
        %disp([num2str(cnt) ' : ' value_name ' : ' tline]);
        
        %temporary fix for the note subfield
        if isempty(value) & strcmp(value_name,'note'); value = 'NOTE:'; end;
        
        if ~isempty(value);
            
            %remove quotations
            if length(value) == 0; value = 'nan'; end;
            if value(1) == '"'; value = value(2:end);end;
            if isempty(value); value = 'nan'; end;
            if value(end) == '"'; value = value(1:(end-1)); end;
            if length(value) == 0; value = 'nan'; end;
            
            %remove parathensis
            if value(1) == '('; value = value(2:end);end;
            if length(value) == 0; value = 'nan'; end;
            if value(end) == ')'; value = value(1:(end-1)); end
            if length(value) == 0; value = 'nan'; end;
            
            %remove carrots
            if value(1) == '^'; value = value(2:end);end;
            if value(end) == '^'; value = value(1:(end-1)); end;
            if length(value) == 0; value = 'nan'; end;
            
            %remove approx
            if value(1) == '~'; value = value(2:end);end;
            if value(end) == '~'; value = value(1:(end-1)); end;
            if length(value) == 0; value = 'nan'; end;
            
            %check to see if we have a multi-line variable
            tline2 = fgetl(fid);
            skip_read = 1;
            if ~ischar(tline2); tline2 = eof_name; end;
            tline2 = lower(strtrim(tline2));
            tline2 = strrep(tline2,' ','');
            if isempty(tline2) | ~isempty(strfind(tline2,'=')) | ...
                    ~isempty(strfind(tline2,'object')) | ~isempty(strfind(tline2,'group')) | ...
                    strcmp(tline2,eof_name);
                %the next value is not a continuation, and we don't read in
                %a new line at the end of the script
                skip_read = 1;
            else;
                %we have a multiline variable, keep concatinating until we
                %find the end
                value = [value tline2];
                tline2 = fgetl(fid);
                if ~ischar(tline2); tline2 = eof_name; end;
                tline2 = lower(strtrim(tline2));
                tline2 = strrep(tline2,' ','');
                while ~isempty(tline2) & isempty(strfind(tline2,'=')) & ...
                        isempty(strfind(tline2,'object')) & isempty(strfind(tline2,'group')) & ...
                        ~strcmp(tline2,eof_name);
                    value = [value tline2];
                    tline2 = lower(strtrim(fgetl(fid)));
                    tline2 = strrep(tline2,' ','');
                    skip_read = 1;
                end;
            end;
            
            %if we have a multi-line variable, remove paranthesis and such
            if 1==1;%~skip_read;
                value = strrep(value,'"','');
                value = strrep(value,'(','');
                value = strrep(value,')','');
                value = strrep(value,'^','');
                value = strrep(value,'~','');
            end;
            
            %check to see if we have a corresponding units tag
            %ISIS 2 VIMS cubs use /* */
            units_pos1 = strfind(value,'/*');
            units_pos2 = strfind(value,'*/');
            if ~isempty(units_pos1) & ~isempty(units_pos2);
                value_units = strtrim(value(units_pos1(1)+2:units_pos2(end)-1));
                value_units = strrep(value_units,' ','_');
                value = value(1:(units_pos1(1)-1));
                units_exist = 1;
            end;
            %ISIS 3 uses '<>'
            units_pos1 = strfind(value,'<');
            units_pos2 = strfind(value,'>');
            if ~isempty(units_pos1) & ~isempty(units_pos2);
                value_units = strtrim(value(units_pos1(1)+1:units_pos2(end)-1));
                value_units = strrep(value_units,' ','_');
                value = value(1:(units_pos1(1)-1));
                units_exist = 1;
            end;
            
            %remove final comma from units lines
            if ~isempty(value);
                if strcmp(value(end),','); value = value(1:end-1); end;
            else;
                value = '-1';
            end;
            
            %check to see if the value is a simple number (convert if so)
            value_fix = fix(strtrim(value));
            value_fix(value_fix == 45) = 48;
            value_fix(value_fix == 46) = 48;
            value_fix(value_fix == 32) = 48;
            if ( (min(value_fix) >= 48 )  & (max(value_fix) <=57) );
                value = str2num(value);
            end;
            
            %check to see if we have a multiple set of numbers seperated by
            %commas
            if ischar(value); 
                comma_pos = strfind(value,',');
            else;
                comma_pos = [];
            end;
            if ~isempty(comma_pos);
                comma_pos = [0 comma_pos (numel(value)+1)];
                %see if this is an array of strings or numbers
                value_temp = value((comma_pos(1)+1):(comma_pos(2)-1));
                value_temp = fix(value_temp);
                value_temp(value_temp == 45) = 48;
                value_temp(value_temp == 46) = 48;
                value_temp(value_temp == 32) = 48;
                if ( (min(value_temp) >= 48 )  & (max(value_temp) <=57) );
                    value_vals = zeros(1,numel(comma_pos)-1);
                    for i=1:(numel(comma_pos)-1);
                        value_vals(i) = str2num(value((comma_pos(i)+1):(comma_pos(i+1)-1)));
                    end;
                else;
                    value_vals = cell(1,numel(comma_pos)-1);
                    for i=1:(numel(comma_pos)-1);
                        value_vals{i} = (value((comma_pos(i)+1):(comma_pos(i+1)-1)));
                    end;
                end;
                value = value_vals;
            end;
            
            
            %populate the output structure
            if ~isempty(value_name);
                eval([eval_string value_name ' = value;']);
                if units_exist;
                    eval([eval_string value_name '_units = value_units;']);
                    units_exist = 0;
                end;
            end;
            
            %display the output for bug checking
            %             if ischar(value);
            %                 disp([eval_string value_name ' = ' value]);
            %             elseif iscell(value);
            %                 disp([eval_string value_name ' = ' value{1}]);
            %             else;
            %                 disp([eval_string value_name ' = ' num2str(value)]);;
            %             end;
            
            if skip_read;
                tline = tline2;
                skip_read = 0;
            else
                tline = fgetl(fid);
                if ~ischar(tline); tline = eof_name; end;
                tline = strtrim(lower(tline));
                tline = strrep(tline,' ','');
            end;
            
        else;
            if skip_read;
                tline = tline2;
                skip_read = 0;
            else
                tline = fgetl(fid);
                if ~ischar(tline); tline = eof_name; end;
                tline = strtrim(lower(tline))
                tline = strrep(tline,' ','');;
            end;
            
            %             tline = fgetl(fid);
            %             if ~ischar(tline); tline = eof_name; end;
            %             tline = strtrim(lower(tline));
        end;
        
        if strcmp(tline,eof_name);
            break
        end;
    else;
        tline = ((fgetl(fid)));
        if ~ischar(tline); tline = eof_name; end;
        tline = strtrim(lower(tline));
        tline = strrep(tline,' ','');
        line_cnt = line_cnt + 1;
        eqpos = findstr('=',tline);
        if ~exist('value_name','var'); value_name = 'NOT YET'; end;
        %  disp([num2str(cnt) ' : ' value_name ' : ' tline]);
    end;
    
    %increment the counter
    cnt = cnt+1;
    
    %end the while loop if tline is "END"
    if strcmp(tline,eof_name); break; end;
    % disp([num2str(cnt) ' : -' tline]);
    
    %end the while loop over the files
end;

%if we have reached the maximum number of lines from maxcnt, exit
if cnt >= maxcnt;
    disp(['Reached Maximum Count Number of ' num2str(maxcnt) ' , Exiting...']);
    if ~exist('info','var');
        info = 'No Data';
    end;
    return;
end;

%close the file
fclose(fid);

%%%%%%%
%%%%%%%
%%%VICAR_LABEL_PARSE
%%%%%%%
%%%%%%%
function [info] = vicar_label_parse(filename);

%open the file for reading
fid = fopen(filename,'r');

%start the info structure up with a vicar format string
info.fileformat = 'vicar';

%load the first 24 bytes to get the lblsize info
label = char(fread(fid,24,'char'));
label = strtrim(label');

%make sure the format makes sense
if ~strcmp(label(1:7),'LBLSIZE');
    disp(['Unknown VICAR Format For Label Size : ' label(1:7)]);
    disp('Returning...');
    info = -1;
    return;
end;

%get the number of bytes in the label
pos_eq = strfind(label,'=');
if ~isempty(pos_eq);
    label(1:pos_eq(1)) = strrep(label(1:pos_eq(1)),' ','_');
end;
pos_bl = strfind(label,' ');
if isempty(pos_eq);
    disp(['Unknown VICAR Format For Label Size : ' label(1:7)]);
    disp('Returning...');
    info = -1;
    return;
else;
    if isempty(pos_bl);
        lblsize = str2num( label(pos_eq(1)+1:end));
    else;
        lblsize = str2num( label(pos_eq(1)+1:pos_bl(1)-1));
    end;
end;

%move back to the begining of the file
fseek(fid,0,'bof');

%read the label text data
label = char(fread(fid,lblsize,'char'));
label = strtrim(label');

%for convienience keep a fixed version of the label around
label_fix = fix(label);

%close the file
fclose(fid);

%VICAR labels are easier to decipher because they do not have objects and
%groups like ISIS and PDS label, so we just have to find the number of "="
%signs to know how many variables we need to convert
eq_pos = strfind(label,'=');

%through out any eq_pos positins with lower case letters just to their left
test_vals = label_fix( (eq_pos-1) );
good_ind = find( (test_vals >= 48 & test_vals <=57 ) | ...
    (test_vals >= 65 & test_vals <= 90) );
eq_pos = sort(eq_pos(good_ind));

%step through each equal sign position and parse the value name string
for i=1:numel(eq_pos);
    %first get the variable name by moving left from the equal signs to the
    %first space or the begining of the file
    bl_pos = strfind(label(1:eq_pos(i)),' ');
    if isempty(bl_pos);
        name = label(1:eq_pos(i)-1);
        bl_pos = 0;
    else;
        name = label(bl_pos(end)+1 : eq_pos(i)-1);
    end;
    %determine the start position for the variable name
    start_pos(i) = bl_pos(end)+1;
    %save the variable name
    names{i} = name;
end;

%now step through each equal sign position and parse the value strings
for i=1:numel(eq_pos);
    %the starting point is one to the right of the equals sign
    s_pos = eq_pos(i)+1;
    
    %the ending point is just before the last string to the left of the
    %next value name
    if i~=numel(eq_pos);
        e_pos = find( label_fix(s_pos:start_pos(i+1)-1) ~= 32 );
    else;
        e_pos = find( label_fix(s_pos:end) ~= 32 );
    end;
    if isempty(e_pos);
        value ='';
        values{i} = '';
    else;
        e_pos = e_pos(end)+s_pos-1;
        %now get the value string
        value = label(s_pos:e_pos);
        values{i} = strtrim(value);
    end;
end;

%now step through each value string and prase it appropriately
for j=1:numel(values);
    %get value string
    value = values{j};
    value = strtrim(value);
    
    %remove any special characters
    value = strrep(value,'"','');
    value = strrep(value,'(','');
    value = strrep(value,')','');
    value = strrep(value,'^','');
    value = strrep(value,'~','');
    value = strrep(value,'''','');
    
    %check to see if the value is a simple number (convert if so)
    value_fix = fix(strtrim(value));
    value_fix(value_fix == 45) = 48;
    value_fix(value_fix == 46) = 48;
    value_fix(value_fix == 32) = 48;
    if ( (min(value_fix) >= 48 )  & (max(value_fix) <=57) );
        value = str2num(value);
    end;
    
    %check to see if we have a multiple set of numbers seperated by
    %commas
    comma_pos = strfind(value,',');
    if ~isempty(comma_pos);
        comma_pos = [0 comma_pos (numel(value)+1)];
        %see if this is an array of strings or numbers
        value_temp = value((comma_pos(1)+1):(comma_pos(2)-1));
        value_temp = fix(value_temp);
        value_temp(value_temp == 45) = 48;
        value_temp(value_temp == 46) = 48;
        value_temp(value_temp == 32) = 48;
        if ( (min(value_temp) >= 48 )  & (max(value_temp) <=57) );
            value_vals = zeros(1,numel(comma_pos)-1);
            for i=1:(numel(comma_pos)-1);
                value_vals(i) = str2num(value((comma_pos(i)+1):(comma_pos(i+1)-1)));
            end;
        else;
            value_vals = cell(1,numel(comma_pos)-1);
            for i=1:(numel(comma_pos)-1);
                value_vals{i} = (value((comma_pos(i)+1):(comma_pos(i+1)-1)));
            end;
        end;
        value = value_vals;
    end;
    
    %if this is the last element, clear up any noncharacter values
    if i==numel(eq_pos);
        value_fix = value;
        value = value(value_fix > 0);
        clear value_fix
    end;
    
    %convert value to lower if it is a string
    if ischar(value);
        value = lower(value);
    elseif iscell(value);
        for k=1:numel(value);
            if ischar(value{k});
                value{k} = lower(value{k});
            end;
        end;
    end;
    
    %populate the output structure (using lower case)
    name = lower(names{j});
    name = strrep(name,' ','_');
    eval(['info.' name ' = value;']);
    units_exist=0;
    if units_exist;
        eval([eval_string value_name '_units = value_units;']);
        units_exist = 0;
    end;
    
end;