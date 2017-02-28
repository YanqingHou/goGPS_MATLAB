%   CLASS goGUIclass
% =========================================================================
%
% DESCRIPTION
%   Class for the management of the main goGPS GUI
%
% EXAMPLE
%   gc = goGUIclass();
%
% FOR A LIST OF CONSTANTs and METHODS use doc goGUIclass

%--- * --. --- --. .--. ... * ---------------------------------------------
%               ___ ___ ___
%     __ _ ___ / __| _ | __|
%    / _` / _ \ (_ |  _|__ \
%    \__, \___/\___|_| |___/
%    |___/                    v 0.5.0
%
%--------------------------------------------------------------------------
%  Copyright (C) 2009-2017 Mirko Reguzzoni, Eugenio Realini
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, Eugenio Realini, ...
%  A list of all the historical goGPS contributors is in CREDITS.nfo
%--------------------------------------------------------------------------
%
%   This program is free software: you can REDistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%--------------------------------------------------------------------------
% 01100111 01101111 01000111 01010000 01010011
%--------------------------------------------------------------------------

classdef goGUIclass < handle

    % =========================================================================
    %   PROPERTIES
    % =========================================================================
    
    properties (Constant)        
        % Colors
        DISABLE_COL = [0.502 0.502 0.502];  % Grey (disabled color)
        ENABLE_COL = [0 0 0];               % Black (enabled color)
        GREEN = [0 0.8 0];                  % Green - for flag
        YELLOW = [1 0.8 0.1];               % Yellow - for flag
        RED = [1 0 0];                      % Red - for flag
        BLUE = [0 0 1];                     % Blue - for flag
                
        % processing rates used in UI -> to convert UI to settings format
        UI_P_SRATE = [1/10 1/5 1/2 1 5 15 30];
        
        % capture rates used in UI -> to convert UI to settings format
        UI_C_SRATE = [1 1/2 1/5 1/10];
    end

    properties (GetAccess = 'private', SetAccess = 'private')

    %  HANDLERS
    % =========================================================================
        
        w_bar = [];                    % waitbar handle
        logger = Logger.getInstance(); % Handler to the logger object

        goh = [];                      % goGPS gui handler
        
        edtINI = [];              % Handler to everything related to the editor pf the ini files
                                  
        status; % DEPRECATE: structure containing the state of the parameters of the figure
        
        state = GO_Settings.getCurrentSettings(); % Object that will contain all the settings for goGPS
        
    %  INTERFACE STATUS
    % =========================================================================
        
        curState = [];      % This array [n x 1] contains the current status of abilitation of each element of the interface
        newState = [];      % This array [n x 1] contains the future status of abilitation of each element of the interface
        initialState = [];  % This array [n x 1] contains a saved status of abilitation of each element of the interface
        
        getFlag = [];       % Logical flag array [n x 1] contain 1 where a change of the value of the element is needed (from UI to current status)
        setFlag = [];       % Logical flag array [n x 1] contain 1 where a change of the value of the element is needed (from current status to UI)
        curVal = {};        % contains the value of each element of the interface, if one of the element has no value the cell is empty
        newVal = {};        % contains the value of the element of the interface that require to be channged
        
        initialized = 0;    % Logical containing the status of initialization if the GUI
        echoChar = '*';     % Character for masking the password
        
    %  INTERFACE STATUS - PATH
    % =========================================================================        
    %  Deprecate, everything should be moved into config.ini
    
        intSettingsDir = '../data/old/settings/'; % Settings folder of goGPS, it contains default settings files
        settingsDir = '../data/old/settings/';    % Settings folder of goGPS, it contains all the other settings files
        workingDir = '../data/';                        % Working folder of goGPS, it contains data files/folders
        defaultINIKeywordsFile = 'goGPS_iniDefaultKeywords.ini'; % File containing hint parameters for building an ini files
        
    %  POP UP MENUS
    % ======================================================================
    % Look initPopUps for the complete initialization

        % Processing Mode
        idRealTime = 1;     % id of the pop-up menu Processing mode for Real Time
        idPostProc = 2;     % id of the pop-up menu Processing mode for Post processing
        strMode = {};       % string containing the pop-up menu fields
        
        % Capture mode
        idNav = 1;           % Navigation + capture
        idRMon = 2;          % Rover monitoring (only Rover capture)
        idMMon = 3;          % Master monitoring (only Master capture)
        idRMMon = 4;         % Rover + Master monitoring (Rover and Master capture)
        strCaptureMode = {}; % string containing the pop-up menu fields
        
        % Algorithm type
        idLS = 1;          % Least Squares
        idKF = 2;          % Kalman Filter
        idSEID = 3;        % Satellite-specific Epoch-differenced Ionospheric Delay (SEID) model
        strAlgorithm = {}; % string containing the pop-up menu fields
        
        % Processing type
        idC_SA = 1;      % Code stand-alone (i.e. undifferenced)
        idC_DD = 2;      % Code double difference
        idCP_DD_L = 3;   % Code double difference with LAMBDA
		idCP_Vel = 4;    % Variometric approach for velocity estimation
        idCP_SA = 3;     % Code and phase stand-alone (i.e. undifferenced)    
        idCP_DD = 4;     % Code and phase double difference
        idC_SA_MR = 5;   % Code and phase stand-alone (i.e. undifferenced) for multiple receivers
        idCP_DD_MR = 6;  % Code and phase double difference for multiple receivers
        idSEID_RO = 1;   % Seid to generate a rinex files containing a fake L2
        idSEID_PPP = 2;  % Generation of the rinex using SEID followed by PPP
        
        strTypeLS    = {};  % string containing the pop-up menu fields
        strTypeKF    = {};  % string containing the pop-up menu fields        
        strTypeSEID  = {};  % string containing the pop-up menu fields                        
        
        % Integer ambiguity resolution method
        idILS_enum_old = 1;   % ILS method based enumeration in search             (LAMBDA 2.0)
        idILS_shrink = 2;     % ILS method based on search-and-shrink              (LAMBDA 3.0)
        idILS_enum = 3;       % ILS method based enumeration in search             (LAMBDA 3.0)
        idIntRound = 4;       % integer rounding method                            (LAMBDA 3.0)
        idIntBootstr = 5;     % integer bootstrapping method                       (LAMBDA 3.0)
        idPAR = 6;            % PAR with the input P0 of user-defined success rate (LAMBDA 3.0)
        strLAMBDAMethod = {}; % String containing the pop-up menu fields
        
        % Dynamic model
        idCVel = 1;          % Costant velocity
        idCAcc = 2;          % Costant acceleration
        idStatic = 3;        % Static model
        idVariable = 4;      % Variable model
        strDynModel = {};    % String containing the pop-up menu fields
        idMonConstant = 1;   % Monitor mode constant
        idMonVariable = 2;   % Monitor mode variable
        strMonDynModel = {}; % String containing the pop-up menu fields
        
        % Ports
        strPorts = {};       % String containing the pop-up menu fields
        
        % Master station
        idXYZ = 1;           % Pop up Master station (id in the pop-up for idXYZ)
        idGeodetic = 2;      % Pop up Master station (id in the pop-up for idGeodetic)
        
        % Data usage
        strProcRate = {};    % Pop up Rate of processing
        valProcRate = [];    % float values of the processing rate
                
        % Observation modelling
        strIonoModel = {};   % Pop up list of ionospheric models
        strTropoModel = {};  % Pop up list of tropospheric models

    %  OTHER IDs
    % ======================================================================
    
        ledOff = 0;          % Led status off
        ledOn  = 1;          % Led status on
        ledOk  = 3;          % Led status ok
        ledKo  = 4;          % Led status ko
        ledCk  = 5;          % Led status check
        ledOp  = 6;          % Led status optional parameter
        
    %  Interface Strings
    % ======================================================================
        
        % These are the displayed text for 
        % Rover/Master (LS, KF) or
        % Source/Target (SEID)
        str_source_rover = {'Source (multi-freq) RINEX obs. file', 'RINEX rover observation file'}; % Strings for different status of the interface (Source / Target)
        str_target_master = {'Target (single-freq) RINEX obs. file', 'RINEX master observation file'}; % Strings for different status of the interface (Rover / Master)    
    end
    
    properties (GetAccess = 'public', SetAccess = 'private')
    
    %  ELEMENT IDS
    % ======================================================================
    % Each element of the interface has an id, this is needed to search
    % inside the interface status its values and enable mode
    
        idUI;               % Structure containing all the UI identifiers
        idGroup;            % Structure containing groups of elements        
        
        id2handle;          % Array n x 2 containing at the idUI index the handle of the object in the GUI
    end
    
    % =========================================================================
    %   METHODS
    % =========================================================================
    
    %   CREATOR DESTRUCTOR and INIT
    % -------------------------------------------------------------------------
    % functions to be used to modify the GUI properties    
    methods
        %   CREATOR / DESTRUCTOR
        % =================================================================
        
        % Creator (Brahma)
        function this = goGUIclass(handles)            
            % Creator (Brahma)
            this.init(handles);
        end        
                
        % Destructor (Shiva)
        % function delete(this); end
    end
    
    % Internal Init functions
    methods(Access = 'private')
        
        % Init all the UI
        function init(this, handles)
            % Init all the UI
            clear global goIni

            tic;
            this.w_bar = Go_Wait_Bar.getInstance(5,'Initializing goGPS GUI...');
            this.w_bar.createNewBar('Init GUI');
            this.goh = handles;  % Save the handle of the figure
            
            % Init logo
            [logo, map, transparency] = imread(this.state.getLogo());
            image(logo, 'AlphaData', transparency);
            axis off;
            
            % Init pup-up strings
            this.initPopUps();
            
            % Choose default command line output for gui_goGPS
            this.goh.output = this.goh.main_panel;
            
            set(this.goh.main_panel,'CloseRequestFcn',@this.closeGUI);            
              
            % Update handles structure
            guidata(this.goh.main_panel, this.goh);
                
            this.w_bar.goMsg('Centering interface...');
            
            %pixels
            set(this.goh.main_panel, 'Units', 'pixels' );
            
            %get display size
            screenSize = get(0, 'ScreenSize');
            
            %calculate the center of the display
            position = get(this.goh.main_panel, 'Position');
            position(1) = (screenSize(3)-position(3))/2;
            position(2) = (screenSize(4)-position(4))/2;
            
            %center the window
            set(this.goh.main_panel, 'Position', position);

            % Init elements ids
            this.initInterface();
            this.w_bar.close();
            t0 = toc;
            fprintf('goGPS GUI initialization completed in %.2f seconds\n', t0);
        end

        % Fill all the Pop-up menus
        function initPopUps(this)
            % Fill all the Pop-up menus

            % Processing Mode
            this.strMode{this.idRealTime} = 'Real-time';
            this.strMode{this.idPostProc} = 'Post-processing';
                        
            this.strCaptureMode{this.idNav} = 'Navigation';
            this.strCaptureMode{this.idRMon} = 'Rover Monitor';
            this.strCaptureMode{this.idMMon} = 'Master Monitor';
            this.strCaptureMode{this.idRMMon} = 'Rover and Master Monitor';

            this.strAlgorithm{this.idLS} = 'Least squares';
            this.strAlgorithm{this.idKF} = 'Kalman filter';
            this.strAlgorithm{this.idSEID} = 'SEID';
            
            this.strTypeLS{this.idC_SA} = 'Code undifferenced';
            this.strTypeLS{this.idC_DD} = 'Code double difference';
            this.strTypeLS{this.idCP_DD_L} = 'Code and phase double difference (for LAMBDA)';
			this.strTypeLS{this.idCP_Vel} = 'Variometric approach for velocity estimation';
            %this.strTypeLS{this.idC_SA_MR} = 'Code undifferenced for multiple receivers';
            %this.strTypeLS{this.idCP_DD_MR} = 'Code and phase double difference for multiple receivers';

            this.strTypeKF{this.idC_SA} = 'Code undifferenced';
            this.strTypeKF{this.idC_DD} = 'Code double difference';
            this.strTypeKF{this.idCP_SA} = 'Code and phase undifferenced (PPP)';
            this.strTypeKF{this.idCP_DD} = 'Code and phase double difference';
            %this.strTypeKF{this.idCP_DD_MR} = 'Code and phase double difference for multiple receivers';
            
            this.strTypeSEID{this.idSEID_RO} = 'SEID Rinex only';
            this.strTypeSEID{this.idSEID_PPP} = 'SEID followed by KF PPP';

            this.strLAMBDAMethod{this.idILS_enum_old} = 'LAMBDA 2.0 - ILS, enumeration';
            this.strLAMBDAMethod{this.idILS_shrink}   = 'LAMBDA 3.0 - ILS, search-and-shrink';
            this.strLAMBDAMethod{this.idILS_enum}     = 'LAMBDA 3.0 - ILS, enumeration';
            this.strLAMBDAMethod{this.idIntRound}     = 'LAMBDA 3.0 - Integer rounding';
            this.strLAMBDAMethod{this.idIntBootstr}   = 'LAMBDA 3.0 - Integer bootstrapping';
            this.strLAMBDAMethod{this.idPAR}          = 'LAMBDA 3.0 - Partial ambiguity resolution';
            
            this.strDynModel{this.idCVel} = 'Const. velocity';
            this.strDynModel{this.idCAcc} = 'Const. acceleration';
            this.strDynModel{this.idStatic} = 'Static';
            this.strDynModel{this.idVariable} = 'Variable';
            
            this.strMonDynModel{this.idMonConstant} = 'Constant';
            this.strMonDynModel{this.idMonVariable} = 'Variable';
            
            this.strPorts{1} = '1';
            this.strPorts{2} = '2';
            this.strPorts{3} = '3';
            this.strPorts{4} = '4';                        
            this.initPorts(this.strPorts);
            
            this.strProcRate{1} = '10 Hz';
            this.strProcRate{2} = ' 5 Hz';
            this.strProcRate{3} = ' 2 Hz';
            this.strProcRate{4} = ' 1 Hz';
            this.strProcRate{5} = ' 5 s';
            this.strProcRate{6} = '15 s';
            this.strProcRate{7} = '30 s';
            this.valProcRate = [1/10 1/5 1/2 1 5 15 30];
            this.initProcRate(this.strProcRate, 4);

            this.strIonoModel{1} = 'no model';
            this.strIonoModel{2} = 'Geckle and Feen model';
            this.strIonoModel{3} = 'Klobuchar model';
            this.strIonoModel{4} = 'SBAS grid';
            this.initIonoModel(this.strIonoModel, 3);
            
            this.strTropoModel{1} = 'no model';
            this.strTropoModel{2} = 'Saastamoinen model (with standard atmosphere parameters)';
            this.strTropoModel{3} = 'Saastamoinen model (with Global Pressure Temperature model)';
            this.initTropoModel(this.strTropoModel, 2);

        end
        
        % Fill the CaptureMode pop-up (Navigation, Monitor...)
        function initCaptureMode(this, str)
            % Fill the CaptureMode pop-up (Navigation, Monitor...)
            
            if nargin < 2
                str = this.strCaptureMode;
            end
            value = get(this.goh.nav_mon,'Value');
            value = min(1,max(length(str), value));
            set(this.goh.nav_mon,'Value', value);
            set(this.goh.nav_mon,'String', str);
        end
        
        % Fill the AlgorithmType pop-up (LS, KF...)
        function initAlgorithmType(this, str)
            % Fill the AlgorithmType pop-up (LS, KF...)
            if nargin < 2
                str = this.strAlgorithm;
            end
            value = get(this.goh.kalman_ls,'Value');
            value = min(1,max(length(str), value));
            set(this.goh.kalman_ls,'Value', value);
            set(this.goh.kalman_ls,'String', str);
        end

        % Fill the ProcessingType pop-up (C_SA, CP_DD, ...)
        function initProcessingType(this, str)
            % Fill the ProcessingType pop-up (C_SA, CP_DD, ...)
            if nargin < 2
                if get(this.goh.kalman_ls,'Value') == this.idLS
                    str = this.strTypeLS;
                elseif get(this.goh.kalman_ls,'Value') == this.idKF
                    str = this.strTypeKF;
                else
                    str = this.strTypeSEID;                    
                end
            end
            value = get(this.goh.code_dd_sa,'Value');
            value = max(1,min(length(str), value));
            set(this.goh.code_dd_sa,'Value', value);
            set(this.goh.code_dd_sa,'String', str);
        end
        
        % Fill the LAMBDA method pop-up (ILS_shrink, ILS_enum, ...)
        function initLAMBDAMethod(this, str)
            % Fill the LAMBDA method pop-up (ILS_shrink, ILS_enum, ...)
            if nargin < 2
                str = this.strLAMBDAMethod;
            end
            value = get(this.goh.lLAMBDAMethod,'Value');
            value = max(1,min(length(str), value));
            set(this.goh.lLAMBDAMethod,'Value', value);
            set(this.goh.lLAMBDAMethod,'String', str);
        end
        
        % Fill the Dynamic Model pop-up (constant velocity, acceleration...)
        function initDynModel(this, str)
            % Fill the Dynamic Model pop-up (constant velocity, acceleration...)        
            if nargin < 2
                str = this.strDynModel;
            end
            value = get(this.goh.dyn_mod,'Value');
            value = max(1,min(length(str), value));
            set(this.goh.dyn_mod, 'String', str);
            set(this.goh.dyn_mod,'Value', value);            
        end
        
        % Dyn model changes wrt the mode
        function resetDynModel(this)
            % Dyn model changes wrt the mode
            if this.isRealTime()
                switch this.getElVal(this.idUI.lCaptMode)
                    case this.idNav
                        % Full: cv, ca, static, var
                        this.initDynModel(this.strDynModel);
                    otherwise
                        % Constant / variable 
                        this.initDynModel(this.strMonDynModel);
                end
            else
                switch this.getElVal(this.idUI.lProcType)
                    case {this.idCP_DD, this.idCP_DD_MR}
                        % Full: cv, ca, static, var
                        this.initDynModel(this.strDynModel);
                    otherwise 
                        % cv, ca, static
                        this.initDynModel(this.strDynModel(1:3));
                end
            end
        end
        
        % Fill the processing rate pop-up list
        function initProcRate(this, str, defaultVal)
            % Fill the processing rate pop-up list
            if nargin == 2
                defaultVal = 1;
            end
            set(this.goh.lProcRate, 'String', str);
            set(this.goh.lProcRate, 'Value', defaultVal);
        end
        
        % Fill the ionospheric model pop-up list
        function initIonoModel(this, str, defaultVal)
            % Fill the ionospheric model pop-up list
            if nargin == 2
                defaultVal = 3;
            end
            defaultVal = max(1,min(defaultVal, length(str)));            
            set(this.goh.lIono, 'String', str);
            set(this.goh.lIono, 'Value', defaultVal);
        end
        
        % Fill the tropospheric model pop-up list
        function initTropoModel(this, str, defaultVal)
            % Fill the tropospheric model pop-up list
            if nargin == 2
                defaultVal = 2;
            end
            defaultVal = max(1,min(defaultVal, length(str)));
            set(this.goh.lTropo, 'String', str);
            set(this.goh.lTropo, 'Value', defaultVal);
        end
        
        % Fill the num ports pop-up list
        function initPorts(this, str)
            % Fill the num ports pop-up list
            if nargin < 2
                str = this.strPorts;
            end
            % Set list box with the number of receivers
            value = get(this.goh.num_receivers,'Value');
            value = min(1,max(length(str), value));
            set(this.goh.num_receivers,'Value', value);

            % Close old connections that are still open:
            try
                oldConnections = instrfind('Type', 'serial');
                if ~(isempty(oldConnections))
                    fclose(oldConnections);
                end
            catch e
                fprintf('There has been a problem with old serial connections: %s\n', e.message);
            end

            % Detect available ports
            try
                serialInfo = instrhwinfo('serial');
                num_ports = size(serialInfo.AvailableSerialPorts,1);
            catch e
                num_ports = 0;
            end
            
            if num_ports == 0
                set(this.goh.num_receivers,'String','1');
            elseif num_ports <= size(str,1)
                set(this.goh.num_receivers,'String',str(1:num_ports));
            else
                set(this.goh.num_receivers,'String',str);
            end
            
            availablePorts = [];
            try
                availablePorts = serialInfo.AvailableSerialPorts;
            catch e
            end
            if (isempty(availablePorts))
                availablePorts = {'NA'};
            end
            
            set(this.goh.com_select_0,'String', availablePorts);
            set(this.goh.com_select_1,'String', availablePorts);
            set(this.goh.com_select_2,'String', availablePorts);
            set(this.goh.com_select_3,'String', availablePorts);
        end

        % Get the active frequencies
        function active_freq = getFreq(this)
            % Get the active frequencies
            active_freq = [1 2 5 6] .* [this.isActive(this.idUI.cL1) ...
                                        this.isActive(this.idUI.cL2) ...
                                        this.isActive(this.idUI.cL5) ...
                                        this.isActive(this.idUI.cL6)];
            active_freq( active_freq == 0) = [];
            if isempty(active_freq)
                this.setElVal(this.idUI.cL1, true, 0);
                active_freq = 1;
                
            end
        end
        
        % Get observation combination
        function obs_comb = getObsComb(this)
            % Get observation combination
            if (this.isEnabled(this.idUI.lObsComb))  % To be active an elment must be Enabled and its value = 'on'
                obs_comb_val = this.getElVal(this.idUI.lObsComb);
            else
                obs_comb_val = 1;
            end
            if obs_comb_val == 2
                obs_comb = 'IONO_FREE';                
            else
                obs_comb = 'NONE';
            end                
        end
        
        % Fill the available ports pop-ups
        function [select_0 select_1 select_2 select_3] = getPortValues(this, s0, s1, s2, s3)
            % Fill the available ports pop-ups
            contents = get(this.goh.com_select_0,'String');
            select_0 = 1; select_1 = 1; select_2 = 1; select_3 = 1;
            for i = 1 : numel(contents)
                if (strcmp(contents{i},s0))
                    select_0 = i;
                elseif (strcmp(contents{i},s1))
                    select_1 = i;
                elseif (strcmp(contents{i},s2))
                    select_2 = i;
                elseif (strcmp(contents{i},s3))
                    select_3 = i;
                end
            end

        end
        
        % Get working directory
        function wdir = getWorkingDir(this)
            % Get working directory
            wdir = this.workingDir;
            if isempty(wdir)
                wdir = './';
            end
            if wdir == 0
                wdir = './';
            end
            wdir = checkPath(wdir);
        end
        
        % Get settings directory
        function sdir = getSettingsDir(this)
            % Get settings directory
            sdir = this.intSettingsDir;
            if isempty(sdir)
                sdir = './';
            end
            if sdir == 0
                sdir = './';
            end
            sdir = checkPath(sdir);
        end
    end
    
    %   INTERNAL OBJ STRUCTURE    < = >    GUI
    % -------------------------------------------------------------------------
    % Functions to match the this internal structure and the goGPS GUI
    % All the functions that could modify directly the object status
    % (acting on this.goh handle) should be here.
    methods (Access = 'private');
      
        % Set an id value for the each User Interface element
        % This is the most important function containing the entire 
        % configuration of the interface.
        % To add an element in the interface (and to be able to manage it
        % from this object follow these steps:
        %
        %  1. Add an id (with incremental i value)
        %      i=i+1;  id.<name> = i;
        %
        %  2. Associate to this id the correct handle
        %      id2h(i) = this.goh.<handle>;
        %
        function initUIids(this)
            % Set an id value for the each User Interface element
            % Rough pre-allocation
            id2h = zeros(177,1);	% rough estimation of the handle array size
                                    % at the end of the function it will contain the exact size

            % Id naming convections:
            %  p    panels
            %  t    text fields (passive)
            %  s    text fields (active)
            %  n    text fields containing numbers
            %  c    check boxes
            %  r    radio buttons
            %  l    list boxes
            %  f    LED
            %  g    groups
                        
          %   MAIN FIG
          % --------------------------------------------------------------- 
            
            i=1;   id.Fig           = i;    id2h(i) = this.goh.main_panel;
            
            i=i+1; id.tTitle        = i;    id2h(i) = this.goh.txtTitle;
            i=i+1; id.tDesc         = i;    id2h(i) = this.goh.txtDescription;
            
          %   PANELS
          % --------------------------------------------------------------- 
            
            i=i+1; id.pMode         = i;    id2h(i) = this.goh.uipMode;
            i=i+1; id.pUsage        = i;    id2h(i) = this.goh.uipUsage;
            i=i+1; id.pOptions      = i;    id2h(i) = this.goh.uipOptions;
            i=i+1; id.pOutliers     = i;    id2h(i) = this.goh.pOutliers;
            i=i+1; id.pConstellations = i;  id2h(i) = this.goh.uipConstellations;
            i=i+1; id.pIntAmb       = i;    id2h(i) = this.goh.pIntAmb;
            i=i+1; id.pIOFiles      = i;    id2h(i) = this.goh.uipInOutFiles;
            i=i+1; id.pKF           = i;    id2h(i) = this.goh.uipKF;
            i=i+1; id.pEStD         = i;    id2h(i) = this.goh.uipEStD;
            i=i+1; id.pOM           = i;    id2h(i) = this.goh.pObsModelling;
            i=i+1; id.pDynModel     = i;    id2h(i) = this.goh.dynamic_model_panel;
            i=i+1; id.pARAA         = i;    id2h(i) = this.goh.ARAA_panel;
            i=i+1; id.pMSt          = i;    id2h(i) = this.goh.uipMaster;
            i=i+1; id.pPorts        = i;    id2h(i) = this.goh.uipPorts;
            i=i+1; id.pMS_NTRIP     = i;    id2h(i) = this.goh.uipMS_NTRIP;
                        
          %   MODE
          % --------------------------------------------------------------- 
            
            i=i+1; id.lProcMode     = i;    id2h(i) = this.goh.mode;  
            i=i+1; id.lCaptMode     = i;    id2h(i) = this.goh.nav_mon;
            i=i+1; id.lAlgType      = i;    id2h(i) = this.goh.kalman_ls;
            i=i+1; id.lProcType     = i;    id2h(i) = this.goh.code_dd_sa;
            i=i+1; id.cTropo        = i;    id2h(i) = this.goh.flag_tropo;
            
            idG.pMode = [id.pMode id.lProcMode:id.cTropo];
            
          %   DATA SELECTION
          % --------------------------------------------------------------- 
            
            i=i+1; id.cL1     = i;    id2h(i) = this.goh.cL1;  
            i=i+1; id.cL2     = i;    id2h(i) = this.goh.cL2;  
            i=i+1; id.cL5     = i;    id2h(i) = this.goh.cL5;  
            i=i+1; id.cL6     = i;    id2h(i) = this.goh.cL6;
            
            i=i+1; id.lProcRate    = i;    id2h(i) = this.goh.lProcRate;  
            i=i+1; id.tProcRate    = i;    id2h(i) = this.goh.text_rate;
            
            i=i+1; id.lObsComb     = i;    id2h(i) = this.goh.lObsComb;  
            i=i+1; id.tObsComb     = i;    id2h(i) = this.goh.text_comb;
            
            idG.pObsComb = [id.lObsComb id.tObsComb];
            idG.pProcRate = [id.lProcRate id.tProcRate];
            idG.pFreq = id.cL1:id.cL6;
            
            i=i+1; id.cOcean        = i;    id2h(i) = this.goh.flag_ocean;

            idG.pUsage = [id.pUsage idG.pProcRate idG.pObsComb idG.pFreq];

          %   CONSTELLATIONS
          % --------------------------------------------------------------- 
            i=i+1; id.cGPS          = i;    id2h(i) = this.goh.cGPS;
            i=i+1; id.cGLONASS      = i;    id2h(i) = this.goh.cGLONASS;
            i=i+1; id.cGalileo      = i;    id2h(i) = this.goh.cGalileo;
            i=i+1; id.cBeiDou       = i;    id2h(i) = this.goh.cBeiDou;
            i=i+1; id.cQZSS         = i;    id2h(i) = this.goh.cQZSS;
            i=i+1; id.cSBAS         = i;    id2h(i) = this.goh.cSBAS;
            
            % Group of ids in the panel pConstellations
            idG.pGNSS = [id.pConstellations id.cGPS id.cGLONASS id.cGalileo id.cBeiDou id.cQZSS id.cSBAS];
            
            % Constellation of satellites currently supported
            idG.pAvailableGNSSCode = [id.cGPS id.cGLONASS id.cGalileo id.cBeiDou id.cQZSS];
            idG.pAvailableGNSSPhase = [id.cGPS id.cGLONASS id.cGalileo id.cBeiDou id.cQZSS];

            % Cut-off thr -------------------------------------------------
            i=i+1; id.tCutOff       = i;    id2h(i) = this.goh.text_cut_off;
            i=i+1; id.nCutOff       = i;    id2h(i) = this.goh.cut_off;
            i=i+1; id.uCutOff       = i;    id2h(i) = this.goh.text_cut_off_unit;
            
            idG.CutOff = [id.tCutOff id.nCutOff id.uCutOff];
            
            % SNR thr -----------------------------------------------------
            i=i+1; id.tSNR          = i;    id2h(i) = this.goh.text_snr_thres;
            i=i+1; id.nSNR          = i;    id2h(i) = this.goh.snr_thres;
            i=i+1; id.uSNR          = i;    id2h(i) = this.goh.text_snr_thres_unit;
            
            idG.SNR = [id.tSNR id.nSNR id.uSNR];
            
            % Min sat number ----------------------------------------------
            i=i+1; id.tMinNSat      = i;    id2h(i) = this.goh.text_min_sat;
            i=i+1; id.nMinNSat      = i;    id2h(i) = this.goh.min_sat;
            
            idG.MaxNumSat = [id.tMinNSat id.nMinNSat];
            
            % Min arcLength number ----------------------------------------------
            
            i=i+1; id.tMinArc      = i;    id2h(i) = this.goh.text_min_arc;
            i=i+1; id.nMinArc      = i;    id2h(i) = this.goh.nMinArc;
            
            idG.MinArc = [id.tMinArc id.nMinArc];
            
          %   OUTLIERS DETECTION
          % --------------------------------------------------------------- 

            i=i+1; id.cOutlier      = i;    id2h(i) = this.goh.flag_rem_outliers;

            % SPP threshold -----------------------------------------------
            
            i=i+1; id.tSPPthr      = i;    id2h(i) = this.goh.text_SPP_thr;
            i=i+1; id.nSPPthr      = i;    id2h(i) = this.goh.nSPPthr;
            i=i+1; id.uSPPthr      = i;    id2h(i) = this.goh.text_SPP_thr_unit;

            idG.SPPthr = id.tSPPthr : id.uSPPthr;
            
            % Code threshold -----------------------------------------------
            
            i=i+1; id.tCodeThr      = i;    id2h(i) = this.goh.text_code_thr;
            i=i+1; id.nCodeThr      = i;    id2h(i) = this.goh.nCodeThr;
            i=i+1; id.uCodeThr      = i;    id2h(i) = this.goh.text_code_thr_unit;
            
            idG.CodeThr = id.tCodeThr : id.uCodeThr;

            % Phase threshold -----------------------------------------------
            
            i=i+1; id.tPhaseThr      = i;    id2h(i) = this.goh.text_phase_thr;
            i=i+1; id.nPhaseThr      = i;    id2h(i) = this.goh.nPhaseThr;
            i=i+1; id.uPhaseThr      = i;    id2h(i) = this.goh.text_phase_thr_unit;
            
            idG.PhaseThr = id.tPhaseThr : id.uPhaseThr;
            
            
            idG.pOutliers = id.cOutlier : id.uPhaseThr;

          %   OPTIONS
          % --------------------------------------------------------------- 

            i=i+1; id.cPrePro       = i;    id2h(i) = this.goh.cPrePro;
            i=i+1; id.cConstraint   = i;    id2h(i) = this.goh.constraint;
            i=i+1; id.cRefPath      = i;    id2h(i) = this.goh.ref_path;
            i=i+1; id.cPlotProc     = i;    id2h(i) = this.goh.plotproc;
            i=i+1; id.cSkyPlot      = i;    id2h(i) = this.goh.no_skyplot_snr;
            i=i+1; id.cGEarth       = i;    id2h(i) = this.goh.google_earth;
            i=i+1; id.cErrEllipse   = i;    id2h(i) = this.goh.err_ellipse;
            i=i+1; id.cPlotMaster   = i;    id2h(i) = this.goh.plot_master;
            i=i+1; id.cPlotAmb      = i;    id2h(i) = this.goh.plot_amb;
            i=i+1; id.cUseNTRIP     = i;    id2h(i) = this.goh.use_ntrip;
            i=i+1; id.cDoppler      = i;    id2h(i) = this.goh.flag_doppler;
            i=i+1; id.cUse_SBAS     = i;    id2h(i) = this.goh.use_SBAS;
            
            % Group of ids in the panel pOptions
            idG.gPlotProc = [id.cSkyPlot id.cGEarth id.cErrEllipse id.cPlotMaster id.cPlotAmb];
            idG.pOptions = [id.pOptions id.cPrePro:id.cUse_SBAS];
                        
          %   INTEGER AMBIGUITY RESOLUTION
          % ---------------------------------------------------------------
          
            i=i+1; id.cLAMBDA       = i;    id2h(i) = this.goh.cLAMBDA;
            i=i+1; id.tLAMBDAMethod = i;    id2h(i) = this.goh.tLAMBDAMethod;
            i=i+1; id.lLAMBDAMethod = i;    id2h(i) = this.goh.lLAMBDAMethod;
            i=i+1; id.tP0           = i;    id2h(i) = this.goh.tP0;
            i=i+1; id.nP0           = i;    id2h(i) = this.goh.nP0;
            i=i+1; id.cP0           = i;    id2h(i) = this.goh.cP0;
            i=i+1; id.tMu           = i;    id2h(i) = this.goh.tMu;
            i=i+1; id.nMu           = i;    id2h(i) = this.goh.nMu;
            i=i+1; id.cMu           = i;    id2h(i) = this.goh.cMu;
            
            idG.gLAMBDAMethod = [id.tLAMBDAMethod id.lLAMBDAMethod];
            idG.gLAMBDA3   = [id.tP0 id.nP0 id.cP0 id.cMu];
            idG.gLAMBDAILS = [idG.gLAMBDA3 id.tMu id.nMu];
            idG.gLAMBDA    = [idG.gLAMBDAMethod idG.gLAMBDAILS];
            idG.pIntAmb    = [id.pIntAmb id.cLAMBDA idG.gLAMBDA];

          %   INPUT/OUTPUT FILE AND FOLDERS
          % --------------------------------------------------------------- 

            % INI ---------------------------------------------------------
            i=i+1; id.tINI          = i;    id2h(i) = this.goh.tINI;
            i=i+1; id.fINI          = i;    id2h(i) = this.goh.fINI;
            i=i+1; id.sINI          = i;    id2h(i) = this.goh.sINI;
            i=i+1; id.bINI          = i;    id2h(i) = this.goh.bINI;
            i=i+1; id.bEditINI      = i;    id2h(i) = this.goh.bEditINI;
            
            idG.gINI = [id.tINI id.fINI id.sINI id.bINI id.bEditINI];
                        
            % Rover -------------------------------------------------------
            i=i+1; id.tRinRover     = i;    id2h(i) = this.goh.tRinRover;
            i=i+1; id.fRinRover     = i;    id2h(i) = this.goh.fRinRover;
            i=i+1; id.tNumRec       = i;    id2h(i) = this.goh.tNumRec;
            
            idG.RinRover = [id.tRinRover id.tNumRec id.fRinRover];
                        
            % Master ------------------------------------------------------
            i=i+1; id.tRinMaster    = i;    id2h(i) = this.goh.tRinMaster;
            i=i+1; id.fRinMaster    = i;    id2h(i) = this.goh.fRinMaster;
            
            idG.RinMaster = [id.tRinMaster id.fRinMaster];
            
            % Navigation --------------------------------------------------
            i=i+1; id.tRinNav       = i;    id2h(i) = this.goh.tRinNav;
            i=i+1; id.fRinNav       = i;    id2h(i) = this.goh.fRinNav;
            
            idG.RinNav = [id.tRinNav id.fRinNav ];            

            % Output ------------------------------------------------------
            i=i+1; id.tDirGoOut     = i;    id2h(i) = this.goh.tDirGoOut;
            i=i+1; id.fDirGoOut     = i;    id2h(i) = this.goh.fDirGoOut;
            i=i+1; id.sDirGoOut     = i;    id2h(i) = this.goh.sDirGoOut;
            i=i+1; id.bDirGoOut     = i;    id2h(i) = this.goh.bDirGoOut;
            i=i+1; id.tPrefixGoOut  = i;    id2h(i) = this.goh.tPrefixGoOut;
            i=i+1; id.sPrefixGoOut  = i;    id2h(i) = this.goh.sPrefixGoOut;
            
            idG.DirGoOut = [id.tDirGoOut id.fDirGoOut id.sDirGoOut id.bDirGoOut];
            idG.GoOut = id.tDirGoOut:id.sPrefixGoOut;

            % DTM ---------------------------------------------------------
            i=i+1; id.tDTM          = i;    id2h(i) = this.goh.tDTM;
            i=i+1; id.fDTM          = i;    id2h(i) = this.goh.fDTM;
            
            idG.DTM = [id.tDTM id.fDTM];
            
            % Reference Path ----------------------------------------------
            i=i+1; id.tRefPath      = i;    id2h(i) = this.goh.tRefPath;
            i=i+1; id.fRefPath      = i;    id2h(i) = this.goh.fRefPath;
            
            idG.RefPath = [id.tRefPath id.fRefPath];
            
            % PCO/PCV file ------------------------------------------------
            i=i+1; id.tPCO          = i;    id2h(i) = this.goh.tPCO;
            i=i+1; id.fPCO          = i;    id2h(i) = this.goh.fPCO;
            
            idG.PCO = [id.tPCO id.fPCO];
            
            % OCEAN LOADING file ------------------------------------------------
            i=i+1; id.tBLQ          = i;    id2h(i) = this.goh.tBLQ;
            i=i+1; id.fBLQ          = i;    id2h(i) = this.goh.fBLQ;
            
            idG.BLQ = [id.tBLQ id.fBLQ];
            
            % STATIONS file ------------------------------------------------
            i=i+1; id.tSTA          = i;    id2h(i) = this.goh.tSTA;
            i=i+1; id.fSTA          = i;    id2h(i) = this.goh.fSTA;
            
            idG.STA = [id.tSTA id.fSTA];
            
            % Group of ids in the panel pIOFiles
            idG.pIOFiles = [id.pIOFiles idG.RinRover idG.RinMaster idG.RinNav idG.GoOut idG.DTM idG.RefPath idG.PCO idG.BLQ idG.STA];
            
            % For a correct LED management these following id groups must be synchronized 
            idG.gFileLED = [id.fINI id.fRinRover id.fRinMaster id.fRinNav id.fDTM id.fRefPath id.fPCO id.fBLQ id.fSTA];
            idG.gInINILED = [id.fRinRover id.fRinMaster id.fRinNav id.fDTM id.fRefPath id.fPCO id.fBLQ id.fSTA];
            idG.gDirLED =  [id.fDirGoOut];
            idG.gLED = [idG.gFileLED idG.gDirLED];

          %   SETTINGS - KALMAN FILTER - STD
          % --------------------------------------------------------------- 

            
            % East --------------------------------------------------------            
            i=i+1; id.nStdE         = i;    id2h(i) = this.goh.std_X;
                        
            % North -------------------------------------------------------            
            i=i+1; id.nStdN         = i;    id2h(i) = this.goh.std_Y;
                        
            % Up ----------------------------------------------------------
            i=i+1; id.nStdU         = i;    id2h(i) = this.goh.std_Z;
            
            % ENU----------------------------------------------------------

            i=i+1; id.tStdENU         = i;    id2h(i) = this.goh.text_std_XYZ;
            i=i+1; id.uStdENU         = i;    id2h(i) = this.goh.text_std_XYZ_unit;
            idG.StdENU = id.nStdE : id.uStdENU;

            
            % Code --------------------------------------------------------
            i=i+1; id.tStdCode      = i;    id2h(i) = this.goh.text_std_code;
            i=i+1; id.nStdCode      = i;    id2h(i) = this.goh.std_code;
            i=i+1; id.uStdCode      = i;    id2h(i) = this.goh.text_std_code_unit;
            
            idG.StdCode = [id.tStdCode id.nStdCode id.uStdCode];
            
            % Phase -------------------------------------------------------
            i=i+1; id.bStdPhase     = i;    id2h(i) = this.goh.toggle_std_phase;
            i=i+1; id.nStdPhase     = i;    id2h(i) = this.goh.std_phase;
            i=i+1; id.uStdPhase     = i;    id2h(i) = this.goh.text_std_phase_unit;
            
            idG.StdPhase = [id.bStdPhase id.nStdPhase id.uStdPhase];
            
            % Initial State -----------------------------------------------
            i=i+1; id.tStdT0        = i;    id2h(i) = this.goh.text_std_init;
            i=i+1; id.nStdT0        = i;    id2h(i) = this.goh.std_init;
            i=i+1; id.uStdT0        = i;    id2h(i) = this.goh.text_std_init_unit;
            
            idG.StdT0 = [id.tStdT0 id.nStdT0 id.uStdT0];
            
            % DTM ---------------------------------------------------------
            i=i+1; id.bStdDTM       = i;    id2h(i) = this.goh.toggle_std_dtm;
            i=i+1; id.nStdDTM       = i;    id2h(i) = this.goh.std_dtm;
            i=i+1; id.uStdDTM       = i;    id2h(i) = this.goh.text_std_dtm_unit;
            
            idG.StdDTM = [id.bStdDTM id.nStdDTM id.uStdDTM];

            % Antenna height ----------------------------------------------
            
            i=i+1; id.tHAntenna     = i;    id2h(i) = this.goh.text_antenna_h;
            i=i+1; id.nHAntenna     = i;    id2h(i) = this.goh.antenna_h;
            i=i+1; id.uHAntenna     = i;    id2h(i) = this.goh.text_antenna_h_unit;
            
            idG.HAntenna = [id.tHAntenna id.nHAntenna id.uHAntenna];
            
            % Velocity ----------------------------------------------------
            i=i+1; id.tStdVel       = i;    id2h(i) = this.goh.text_std_vel;
            i=i+1; id.nStdVel       = i;    id2h(i) = this.goh.std_vel;
            i=i+1; id.uStdVel       = i;    id2h(i) = this.goh.text_std_vel_unit;
            
            idG.StdVel = [id.tStdVel id.nStdVel id.uStdVel];
            
            % Group of ids in the panel pKF
            idG.pKF_ENU = [idG.StdENU];
            idG.pKF = [id.pKF idG.StdENU idG.StdCode idG.StdPhase idG.StdT0 idG.StdDTM idG.StdVel idG.HAntenna];
                                           
          %   SETTINGS - OBSERVATION MODELLING
          % --------------------------------------------------------------- 
             
            i=i+1; id.tWeight        = i;    id2h(i) = this.goh.text_weight;
            i=i+1; id.lWeight        = i;    id2h(i) = this.goh.lWeight;
            i=i+1; id.tIono          = i;    id2h(i) = this.goh.text_iono;
            i=i+1; id.lIono          = i;    id2h(i) = this.goh.lIono;
            i=i+1; id.tTropo         = i;    id2h(i) = this.goh.text_tropo;
            i=i+1; id.lTropo         = i;    id2h(i) = this.goh.lTropo;
            
            idG.pWeight = id.tWeight : id.lWeight;
            idG.pIono = id.tIono : id.lIono;
            idG.pTropo = id.tTropo : id.lTropo;
            
            idG.OM = [id.pOM id.tWeight : id.lTropo];

          %   SETTINGS - KALMAN FILTER
          % --------------------------------------------------------------- 

            % CS thr ------------------------------------------------------
            i=i+1; id.tCS           = i;    id2h(i) = this.goh.text_cs_thresh;
            i=i+1; id.nCS           = i;    id2h(i) = this.goh.cs_thresh;
            i=i+1; id.uCS           = i;    id2h(i) = this.goh.text_cs_thresh_unit;

            idG.CS = [id.tCS id.nCS id.uCS];
                                    
            % Stop Go Stop ------------------------------------------------
            i=i+1; id.cStopGoStop   = i;    id2h(i) = this.goh.stopGOstop;
            i=i+1; id.tStopGoStop   = i;    id2h(i) = this.goh.text_stopGOstop;

            idG.StopGoStop = [id.cStopGoStop id.tStopGoStop];
                        
          %   SETTINGS - KALMAN FILTER - DYNAMIC MODEL
          % ---------------------------------------------------------------
            
            i=i+1; id.lDynModel     = i;    id2h(i) = this.goh.dyn_mod;
            
            idG.pDynModel = [id.pDynModel id.lDynModel];
            
          %   SETTINGS - KALMAN FILTER - ARAA
          % ---------------------------------------------------------------
            
            i=i+1; id.lARAA         = i;    id2h(i) = this.goh.amb_select;
            
            idG.pARAA = [id.pARAA id.lARAA];
            
          %   SETTINGS - MASTER STATION
          % ---------------------------------------------------------------
            
            i=i+1; id.cMPos         = i;    id2h(i) = this.goh.master_pos;
            i=i+1; id.lCRS          = i;    id2h(i) = this.goh.crs;
            
            i=i+1; id.tMX           = i;    id2h(i) = this.goh.text_master_X;
            i=i+1; id.nMX           = i;    id2h(i) = this.goh.master_X;
            i=i+1; id.uMX           = i;    id2h(i) = this.goh.text_master_X_unit;
            i=i+1; id.tMY           = i;    id2h(i) = this.goh.text_master_Y;
            i=i+1; id.nMY           = i;    id2h(i) = this.goh.master_Y;
            i=i+1; id.uMY           = i;    id2h(i) = this.goh.text_master_Y_unit;
            i=i+1; id.tMZ           = i;    id2h(i) = this.goh.text_master_Z;
            i=i+1; id.nMZ           = i;    id2h(i) = this.goh.master_Z;
            i=i+1; id.uMZ           = i;    id2h(i) = this.goh.text_master_Z_unit;
            
            idG.gMXYZ = id.tMX:id.uMZ;
            
            i=i+1; id.tMLat         = i;    id2h(i) = this.goh.text_master_lat;
            i=i+1; id.nMLat         = i;    id2h(i) = this.goh.master_lat;
            i=i+1; id.uMLat         = i;    id2h(i) = this.goh.text_master_lat_unit;
            i=i+1; id.tMLon         = i;    id2h(i) = this.goh.text_master_lon;
            i=i+1; id.nMLon         = i;    id2h(i) = this.goh.master_lon;
            i=i+1; id.uMLon         = i;    id2h(i) = this.goh.text_master_lon_unit;
            i=i+1; id.tMh           = i;    id2h(i) = this.goh.text_master_h;
            i=i+1; id.nMh           = i;    id2h(i) = this.goh.master_h;
            i=i+1; id.uMh           = i;    id2h(i) = this.goh.text_master_h_unit;
            
            idG.gMGeodetic = id.tMLat:id.uMh;
                        
            idG.pMSt = [id.pMSt id.cMPos id.lCRS idG.gMXYZ idG.gMGeodetic];
                        
          %   SETTINGS - PORTS
          % ---------------------------------------------------------------
            
            i=i+1; id.tnPorts       = i;    id2h(i) = this.goh.text_num_receivers;
            i=i+1; id.lnPorts       = i;    id2h(i) = this.goh.num_receivers;
            i=i+1; id.lRate         = i;    id2h(i) = this.goh.pumCaptureRate;            
                    
            idG.nPorts = [id.tnPorts id.lnPorts];
            
            i=i+1; id.lPort0        = i;    id2h(i) = this.goh.com_select_0;
            i=i+1; id.lProt0        = i;    id2h(i) = this.goh.protocol_select_0;
            
            idG.lPort0 = [id.lPort0 id.lProt0];
            
            i=i+1; id.lPort1        = i;    id2h(i) = this.goh.com_select_1;
            i=i+1; id.lProt1        = i;    id2h(i) = this.goh.protocol_select_1;
            
            idG.lPort1 = [id.lPort1 id.lProt1];
            
            i=i+1; id.lPort2        = i;    id2h(i) = this.goh.com_select_2;
            i=i+1; id.lProt2        = i;    id2h(i) = this.goh.protocol_select_2;
            
            idG.lPort2 = [id.lPort2 id.lProt2];
            
            i=i+1; id.lPort3        = i;    id2h(i) = this.goh.com_select_3;
            i=i+1; id.lProt3        = i;    id2h(i) = this.goh.protocol_select_3;
            
            idG.lPort3 = [id.lPort3 id.lProt3];
            
            idG.pPorts = [id.pPorts id.tnPorts:id.lPort3];
            
          %   SETTINGS - MASTER SERVER
          % ---------------------------------------------------------------
            
            i=i+1; id.tIPaddr       = i;    id2h(i) = this.goh.text_IP_address;
            i=i+1; id.sIPaddr       = i;    id2h(i) = this.goh.IP_address;
            i=i+1; id.tIPport       = i;    id2h(i) = this.goh.text_port;
            i=i+1; id.sIPport       = i;    id2h(i) = this.goh.port;
            
            idG.pMS = [id.pMS_NTRIP id.tIPaddr:id.sIPport];
            
            i=i+1; id.tMnt          = i;    id2h(i) = this.goh.text_mountpoint;
            i=i+1; id.sMnt          = i;    id2h(i) = this.goh.mountpoint;
            i=i+1; id.tUName        = i;    id2h(i) = this.goh.text_username;
            i=i+1; id.sUName        = i;    id2h(i) = this.goh.username;
            i=i+1; id.tUPass        = i;    id2h(i) = this.goh.text_password;
            i=i+1; id.sUPass        = i;    id2h(i) = this.goh.password; %
            % Moved in first position => it's a JAVA component
            i=i+1; id.bUPass        = i;    id2h(i) = this.goh.show_password;

            idG.gNTRIP = id.tMnt:id.bUPass;
            
            i=i+1; id.tApproxPos    = i;    id2h(i) = this.goh.text_approx_pos;
            i=i+1; id.tVLat         = i;    id2h(i) = this.goh.text_approx_lat;
            i=i+1; id.nVLat         = i;    id2h(i) = this.goh.approx_lat;
            i=i+1; id.uVLat         = i;    id2h(i) = this.goh.text_approx_lat_unit;
            i=i+1; id.tVLon         = i;    id2h(i) = this.goh.text_approx_lon;
            i=i+1; id.nVLon         = i;    id2h(i) = this.goh.approx_lon;
            i=i+1; id.uVLon         = i;    id2h(i) = this.goh.text_approx_lon_unit;
            i=i+1; id.tVH           = i;    id2h(i) = this.goh.text_approx_h;
            i=i+1; id.nVH           = i;    id2h(i) = this.goh.approx_h;
            i=i+1; id.uVH           = i;    id2h(i) = this.goh.text_approx_h_unit;
            
            idG.gApproxPos = id.tApproxPos:id.uVH;
            
            idG.pMS_NTRIP = [idG.pMS idG.gNTRIP idG.gApproxPos];
            
          %   BUTTONS
          % ---------------------------------------------------------------

            i=i+1; id.bExit         = i;    id2h(i) = this.goh.exit;
            i=i+1; id.bLoad         = i;    id2h(i) = this.goh.load_button;
            i=i+1; id.bSave         = i;    id2h(i) = this.goh.save_button;
            i=i+1; id.bGo           = i;    id2h(i) = this.goh.go_button;                 
          
            idG.gBut = id.bExit:id.bGo;
            
            
            
            idG.Fig = id.pMode:id.bGo;
            idG.ResetStatus = [id.tTitle id.tDesc id.lProcMode id.bExit id.bLoad];
            idG.gDTM = [id.nStdDTM id.uStdDTM idG.DTM idG.HAntenna];
                        
          % ---------------------------------------------------------------
          %   EVENTS GROUPS
          % ---------------------------------------------------------------
          
            % On Real Time
            idG.onRealTime = [idG.ResetStatus id.pConstellations ...
                              id.pMode id.lCaptMode ...
                              id.pIOFiles idG.GoOut];
                          
            % On Real Time => Navigation Mode            
            idG.onRT_Nav = [idG.onRealTime idG.pAvailableGNSSPhase ...
                            id.pOptions id.cConstraint id.cRefPath id.cPlotProc id.cUseNTRIP ...
                            id.pKF idG.pKF_ENU idG.StdCode id.bStdPhase idG.StdT0 id.bStdDTM ...
                            idG.OM idG.CutOff idG.SNR idG.CS idG.MaxNumSat idG.StopGoStop ...
                            idG.pDynModel idG.pARAA ...
                            idG.pMSt idG.pMS id.pPorts idG.lPort0 ...
                            idG.SPPthr idG.CodeThr idG.PhaseThr];
          
            % On Real Time => Rover Monitor
            idG.onRT_RMon = [idG.onRealTime idG.pAvailableGNSSCode ...
                             id.lRate ...
                             idG.pDynModel ...
                             id.pOptions ...
                             id.pPorts idG.nPorts idG.lPort0];

            % On Real Time => Master Monitor
            idG.onRT_MMon = [idG.onRealTime ...
                             id.pOptions id.cUseNTRIP ...
                             idG.pMS_NTRIP];

            % On Real Time => Master + Rover Monitor
            idG.onRT_RMMon = [idG.onRealTime idG.pAvailableGNSSPhase ...
                              idG.pDynModel ...
                              id.pOptions id.cUseNTRIP ...
                              id.pPorts idG.nPorts idG.lPort0...
                              idG.pMS_NTRIP];
                                                    
          % ---------------------------------------------------------------
            
            % On Post Proc
            idG.onPostProc = [idG.ResetStatus ...
                              id.pMode id.lAlgType id.lProcType ...
                              idG.gINI...
                              id.pIOFiles id.pConstellations idG.GoOut ...
                              id.pOptions ...
                              idG.CutOff idG.OM ...
                              id.pUsage idG.pProcRate id.cL1 id.cOutlier id.cOcean ...
                              idG.SPPthr idG.CodeThr idG.MinArc id.cPrePro];
            
            % On Post Proc => Least Squares
            idG.onPP_LS = [idG.onPostProc];
                          
            % On Post Proc => Least Squares => Code Stand Alone
            idG.onPP_LS_C_SA = [idG.onPP_LS id.cPlotProc idG.pAvailableGNSSCode ...
                                id.cUse_SBAS id.cL2 ];
            
            % On Post Proc => Least Squares => Code Double Differences
            idG.onPP_LS_C_DD = [idG.onPP_LS id.cPlotProc idG.pAvailableGNSSCode ...
                                id.pMSt id.cMPos idG.SNR];
                          
            % On Post Proc => Least Squares => Code and Phase Double Differences
            idG.onPP_LS_CP_DD_L = [idG.onPP_LS id.cPlotProc idG.pAvailableGNSSPhase ...
                                   idG.StdCode idG.StdPhase ...
                                   id.pMSt id.cMPos idG.pIntAmb idG.PhaseThr];

            % On Post Proc => Least Squares => Code and Phase Velocity estimation
            idG.onPP_LS_CP_Vel = [idG.onPP_LS idG.pAvailableGNSSPhase idG.PhaseThr];
            
            % On Post Proc => Least Squares => Code Stand Alone 
            % => Multi Receivers Mode
            idG.onPP_LS_C_SA_MR = [idG.onPP_LS id.cPlotProc idG.pAvailableGNSSCode ...
                                   id.cUse_SBAS];
            
            % On Post Proc => Least Squares => Code and Phase Double 
            % => Multi Receivers Mode
            idG.onPP_LS_CP_DD_MR = [idG.onPP_LS id.cPlotProc idG.pAvailableGNSSPhase ...
                                   idG.StdCode idG.StdPhase ...
                                   id.pMSt id.cMPos idG.pIntAmb idG.PhaseThr];

            % On Post Proc => On Kalman Filter
            idG.onPP_KF = [idG.onPostProc id.cPlotProc ...
                           idG.pDynModel ...
                           id.pKF id.pEStD idG.pKF_ENU idG.StdCode idG.StdT0 ...
                           idG.SNR idG.MaxNumSat];
                          
            % On Post Proc => On Kalman Filter => Code Stand Alone
            idG.onPP_KF_C_SA = [idG.onPP_KF idG.pAvailableGNSSCode ...
                               id.cUse_SBAS];
            
            % On Post Proc => On Kalman Filter => Code Double Differences
            idG.onPP_KF_C_DD = [idG.onPP_KF idG.pAvailableGNSSCode ...
                                id.pMSt id.cMPos];

            % On Post Proc => On Kalman Filter => Code and Phase Stand Alone (PPP)
            idG.onPP_KF_CP_SA = [idG.onPP_KF idG.pAvailableGNSSPhase ...
                                 idG.StdPhase idG.CS ...
                                 id.cDoppler id.cUse_SBAS  id.cTropo id.cL2 idG.PhaseThr];
            
            % On Post Proc => On Kalman Filter => Code and Phase Double Differences
            idG.onPP_KF_CP_DD = [idG.onPP_KF id.cConstraint idG.pAvailableGNSSPhase ...
                                 idG.StdPhase id.bStdDTM id.cRefPath ...
                                 idG.CS idG.StopGoStop idG.pARAA... 
                                 id.pMSt id.cMPos id.cDoppler idG.pIntAmb idG.PhaseThr];

            % On Post Proc => On Kalman Filter => Code and Phase Double Differences
            % => Multi Receivers Mode
            idG.onPP_KF_CP_DD_MR = [idG.onPP_KF ...
                                    idG.StdPhase ...
                                    idG.CS idG.StopGoStop idG.pARAA... 
                                    id.pMSt id.cMPos id.cDoppler idG.pIntAmb idG.PhaseThr];

            % On Post Proc => SEID < + PPP >
            idG.onPP_SEID_PPP = [idG.onPP_KF idG.pAvailableGNSSPhase ...
                                 idG.StdPhase idG.CS id.pMSt ...
                                 id.cDoppler id.cUse_SBAS id.cTropo id.cL2 idG.PhaseThr];
           % ---------------------------------------------------------------
          
            
            % On RINEX / BIN
            idG.onRin = [idG.RinRover idG.RinMaster idG.RinNav idG.PCO idG.BLQ idG.STA];

            [idG.gPanels idG.strEl idG.valEl] = this.autoElClassification(id2h);
            
            % Save in object
            this.idUI = id;
            this.idGroup = idG;
            this.id2handle = id2h(1:i);
            
            this.curState = false(i,1);
            this.newState = false(i,1);
            this.setFlag = false(i,1);
            this.getFlag = false(i,1);
        end
        
        % Create different groups for each type of element
        % Element that are panels
        % Element with the main content stoRED in:
        %  - 'Value' field
        %  - 'String' field
        function [panel strEl valEl] = autoElClassification(this,id2h)
            % Create different groups for each type of element
            panel = [];
            strEl = [];
            valEl = [];
            for i=1:length(id2h)
                % A panel doesn't have a Style field
                el = get(id2h(i));
                if isfield(el,'Style')                    
                    if sum(strcmp(el.Style, {'edit' 'text'})) > 0
                        strEl = [strEl i];
                    elseif sum(strcmp(el.Style, {'radiobutton', 'checkbox', 'pushbuttons', 'popupmenu'})) > 0
                        valEl = [valEl i];
                    end
                else
                    % A panel doesn't have the field Style
                    % but has the field BorderType
                    if isfield(el,'BorderType')
                        panel = [panel i];
                    end
                end
            end
        end
        
        % Get enable / disable status of the element of the interface
        % This function should be called only once, later in the code
        % the status is kept updated
        function getAllElStatus(this)            
            panels = false(length(this.id2handle),1);
            panels(this.idGroup.gPanels) = true;          % logical indexes of the panels
            idEl = 1:length(this.id2handle);
            idEl = idEl(~panels);						% id of elements that are not panels
            idEl = idEl(this.idUI.pMode:end);			% The only elements to be consideRED starts 
            											% from the principal panel mode
            
            % For each panel
            for i=1:length(this.idGroup.gPanels)
            	this.curState(this.idGroup.gPanels(i)) = this.isGuiPanelOn(this.id2handle(this.idGroup.gPanels(i)));
           	end
           	
           	% For all the other elements
           	for i=1:length(idEl)
            	this.curState(idEl(i)) = this.isGuiElOn(this.id2handle(idEl(i)));
            end
            this.newState = this.curState;
        end
        
        % Enable / Disable various elements in the interface
        % the variable newStatus will decide the future status of the
        % interface (function also known as setGuiElStatus)
        function onoffUIEl(this)
            % Get enable / disable status of the element of the interface
            % Detect modified state (logical array)
            idModified = xor(this.curState, this.newState);
            idModified(this.idUI.Fig) = false; % the figure doesn't change its status;
            
            if (sum(idModified) > 0)
                this.curState = this.newState;
                
                % ids of the modified elements
                % state id of the modified element
                listState = uint8(this.newState)+1;
                state = {'off','on'};
                
                idEl = 1:length(this.id2handle);              % All the elements
                
                % Sets of panels
                panels = false(length(this.id2handle),1);     % init logical panels group
                panels(this.idGroup.gPanels) = true;           % set logical indexes of the panels
                % modified panels
                mPanel = idEl(panels & idModified);
                
                mIdEl = idEl(~panels & idModified);          % id of elements that are not panels that have been modified
                
                % For each modified panel
                for i=1:length(mPanel)
                    this.onoffGuiPanel(this.id2handle(mPanel(i)), state{listState(mPanel(i))});
                end
                
                % For all the other modified elements
                for i=1:length(mIdEl)
                    this.onoffGuiEl(this.id2handle(mIdEl(i)), state{listState(mIdEl(i))});
                end                
            end
        end

        % Get content of the element of the interface 
        function getAllElContent(this)
            % Get content of the element of the interface 
            this.getFlag(this.idUI.Fig) = false; % the figure doesn't change its status;
            if sum(this.getFlag > 0)                
                idEl = 1:length(this.id2handle);              % All the elements
                
                % Sets of panels
                panels = false(length(this.id2handle),1);     % init logical panels group
                panels(this.idGroup.gPanels) = true;           % set logical indexes of the panels
                % modified panels
                mPanel = idEl(panels & this.getFlag);
                
                % Sets of text elements                
                textEl = false(length(this.id2handle),1);     % init logical text elements group
                textEl(this.idGroup.strEl) = true;              % set logical indexes of the text elements
                % Modified LED elements
                mLED = this.idGroup.gLED(this.getFlag(this.idGroup.gLED));
                % Modified text elements
                mTextEl = setdiff(idEl(textEl & this.getFlag), mLED);
                
                mIdEl = setdiff(idEl(~panels & ~textEl & this.getFlag), mLED); % id of elements that are not panels nor text elements that have been modified
                
                % For each modified panel
                for i=1:length(mPanel)
                    this.curVal{mPanel(i)} = this.getGuiElTitle(this.id2handle(mPanel(i)));
                end
                
                % For each modified txt Element
                for i=1:length(mTextEl)
                    this.curVal{mTextEl(i)} = this.getGuiElStr(this.id2handle(mTextEl(i)));
                end

                % For all the LEDs
                for i=1:length(mLED)
                    this.curVal{mLED(i)} = this.getGuiElColor(this.id2handle(mLED(i)));
                end

                % For all the other modified elements
                for i=1:length(mIdEl)
                    this.curVal{mIdEl(i)} = this.getGuiElVal(this.id2handle(mIdEl(i)));
                end
                
                % Update newVal if the size of it is different from curVal
                % It may appen in the initialization process
                if sum(size(this.newVal) == size(this.curVal)) < 2
                    this.newVal = this.curVal;
                end
                this.newVal(this.getFlag) = this.curVal(this.getFlag);
                this.getFlag = false(size(this.getFlag()));
            end

        end

        % Set content of the element of the interface
        function setAllElContent(this)
            % Set content of the element of the interface
            this.setFlag(1) = false; % the figure doesn't change its status;
            
            if (sum(this.setFlag) > 0)
                if (this.setFlag(this.idUI.sUPass))
                    % Password field is the only one to be managed independently
                    this.setFlag(this.idUI.sUPass) = false;
                    this.showPassword();
                end
                
                idEl = 1:length(this.id2handle);              % All the elements
                
                % Sets of panels
                panels = false(length(this.id2handle),1);     % init logical panels group
                panels(this.idGroup.gPanels) = true;           % set logical indexes of the panels
                % modified panels
                mPanel = idEl(panels & this.setFlag);
                
                % Sets of text elements
                textEl = false(length(this.id2handle),1);     % init logical text elements group
                textEl(this.idGroup.strEl) = true;              % set logical indexes of the text elements
                % Modified LED elements
                mLED = this.idGroup.gLED(this.setFlag(this.idGroup.gLED));
                % Modified text elements
                mTextEl = setdiff(idEl(textEl & this.setFlag), mLED);
                
                mIdEl = setdiff(idEl(~panels & ~textEl & this.setFlag), mLED); % id of elements that are not panels nor text elements that have been modified
                
                % For each modified panel
                for i=1:length(mPanel)
                    this.setGuiElTitle(this.id2handle(mPanel(i)), this.newVal{mPanel(i)});
                end
                
                % For each modified txt element
                for i=1:length(mTextEl)
                    this.setGuiElStr(this.id2handle(mTextEl(i)), this.newVal{mTextEl(i)});
                end
                
                % For all the LEDs
                for i=1:length(mLED)
                    this.setGuiElColor(this.id2handle(mLED(i)), this.newVal{mLED(i)});
                end
                
                % For all the other modified elements
                for i=1:length(mIdEl)
                    this.setGuiElVal(this.id2handle(mIdEl(i)), this.newVal{mIdEl(i)});
                end
                
                % Save the status in the object
                this.curVal(this.setFlag) = this.newVal(this.setFlag);
                this.setFlag = false(size(this.setFlag()));
            end
        end        
    end  
    
    %   INTERFACE MANAGEMENT FROM INSIDE THE OBJ
    % -------------------------------------------------------------------------
    % functions to be used to modify the GUI properties
    methods (Access = 'public');
        
        % Get the status of the interface and prepare the Obj for the management of the GUI
        function initInterface(this)
            % Get the status of the interface and prepare the Obj for the management of the GUI
            this.w_bar.goMsg('Loading GUI manager object...');

            % Set value for elements ids
            this.initUIids();
            
            % Set font style for elements ids
            this.setOSappearence();            

            % Read interface status (initialize structures
            this.getAllElStatus();            

            % Create the password field
            this.initPasswordField('password');
            drawnow;
            
            % If the working folder does not exist
            if isempty(dir(this.getSettingsDir()))
                waitfor(msgbox('WARNING: The folder containing the settings is not in the working directory, please chose settings directory!'));
                dname = uigetdir('../','Choose the directory that contains goGPS settings');
                if (dname ~= 0)
                    this.intSettingsDir = [dname '/'];
                    if isempty(dir(this.getWorkingDir()))
                        this.workingDir = [this.getSettingsDir() '../'];
                    end
                end
            end
            
            this.w_bar.goMsg('Loading GUI manager object...');
            this.w_bar.titleUpdate('Import Settings');
            
            % Fill pop up menus
            this.initPopUp(); % Popup are also modified / reloaded in importLegacyStateMatlab
            
            this.w_bar.goMsg('Importing the last used state...');
            
            % load Last Settings
            this.importSettings();

            this.w_bar.goMsg('Completing syncing phase...');
            this.w_bar.titleUpdate('Finishing');
            
            % Read interface status as get from file
            this.initialState = this.curState;            
            
            % Read current ids content
            this.getFlag = true(size(this.curState));
            this.getAllElContent();
                        
            % Disable interface
            % this.disableAll();
            this.checkUIdependencies();

            this.initialized = 1;
        end

        % Add an undocumented password box
        function initPasswordField(this, pwd)
            % Add an undocumented password box
            % Undocumented password box for a better management of a password field
            % Create the widget containing the text
            jPwdINI = javax.swing.JPasswordField;
            jPwdINI.setText(pwd);
            % Substitute the eINI edit box with the Java Scroll Pane
            set(this.goh.uipMS_NTRIP, 'Units', 'pixels');
            set(this.goh.password, 'Units', 'pixels');
            pos = get(this.goh.password,'Position');
            posOff = get(this.goh.uipMS_NTRIP,'Position');
            pos(1:2) = pos(1:2) + posOff(1:2);
            pos(1) = pos(1) + 4;
            pos(3) = pos(3) - 4;
            
            [jPwd, hPwd] = javacomponent(jPwdINI, pos, this.goh.main_panel);
                        
            %this.id2handle((this.id2handle==this.goh.password)) = hPwd;
            %delete(this.goh.password); % I should delete this but it'll generate some problems
            set(this.goh.password,'Visible','off');
            this.goh.jPassword.jpwd = jPwd;
            this.goh.jPassword.hpwd = hPwd;
            this.echoChar = this.goh.jPassword.jpwd.getEchoChar;
            
            this.setPassword(get(this.goh.password,'String'));
        end
        
        % Set new enable / disable status
        % Show all the new values stoRED in the internal state on the GUI
        % Get new values from the GUI
        function updateGUI(this)
            % Set new enable / disable status
            this.onoffUIEl();
            this.getAllElContent();
            this.checkUIdependencies();
            this.setAllElContent();
        end
        
        % Init pop ups
        function initPopUp(this)
            % Init pop ups
            this.initCaptureMode();
            this.initAlgorithmType();
            this.initProcessingType();
            this.initLAMBDAMethod();
            this.initDynModel();
        end
        
        % Set the value of an element
        %  - idEl           is the identifier of the object 
        %                   (see idUI for the list of ids)
        %  - value          could be of any type string/boolean/number
        %  - <autoapply>    if set this.setAllElContent() is automatically
        %                   called after to show immediatly the modification 
        %                   in the GUI
        function setElVal(this, idEl, value, autoapply)
            % Set the value of an element
            if nargin == 3
                autoapply = true;
            end
            this.setFlag(idEl) = true;
            this.newVal{idEl} = value;
            if autoapply
                this.setAllElContent();
            end
        end
        
        % Get the value of an element (from the internal copy of the object)
        function value = getElVal(this, idEl)
            % Get the value of an element (from the internal copy of the object)
            value = this.newVal{idEl};
            if isempty(value)
                value = this.getGuiElVal(this.id2handle(idEl));
                this.setElVal(idEl, value, 0);
            end
        end
                
        % Set the value of an element
        %  - idEl           is the identifier of the object (or group of
        %                   objects (see idUI/idGroup for the list of ids)
        %  - value          could be 0/1 'on'/'off'
        %  - <autoapply>    if set this.setAllElContent() is automatically
        %                   called after to show immediatly the modification 
        %                   in the GUI
        function setElStatus(this, idEl, status, autoapply)
            % Set the value of an element
            if nargin == 3
                autoapply = true;
            end
            if ischar(status)
                if strcmp(status,'on')
                    status = true;
                else 
                    status = false;
                end
            end
            this.newState(idEl) = logical(status);
            if autoapply
                this.onoffUIEl();
            end
        end
        
        % Return the status of abilitation of the element with id = idEl
        function isOn = isEnabled(this, idEl)
            % Return the status of abilitation of the element with id = idEl
            isOn = this.newState(idEl);
        end
        
        % Return 1 if the color of the element with id = idEl is the same of color (This works only for LEDs)
        function isCol = isColor(this, idEl, color)
            % Return 1 if the color of the element with id = idEl is the same of color (This works only for LEDs)
            tmp = this.getElVal(idEl);
            if length(tmp) == 3
                isCol = sum(this.getElVal(idEl) == color) == 3;
            else
                isCol = false;
            end
        end
        
        % Return the status of activation of the element with id = idEl
        function isOn = isActive(this, idEl)
            % Return the status of activation of the element with id = idEl
            if ischar(this.getElVal(idEl))
                if strcmp(this.getElVal(idEl),'on')
                    isOn = true;
                else
                    isOn = false;
                end
            else
                isOn = logical(this.getElVal(idEl));
            end
            isOn = isOn & this.isEnabled(idEl);  % To be active an elment must be Enabled and its value = 'on'
        end
        
        function isOk  = okGo(this, idEl)
            % Test element readyness
            isOk = ~this.isEnabled(idEl);
            if ~isOk
                isOk = this.isColor(idEl, this.GREEN) || this.isColor(idEl, this.BLUE);
            end
        end
                       
        % Disable all the UI elementss but the mode and exit buttons
        function disableAll(this)
            % Disable all the UI elementss but the mode and exit buttons
            this.setElStatus(this.idGroup.Fig, 0, 0);
            this.setElStatus(this.idGroup.ResetStatus, 1, 1);
        end
        
        % TMP: Testing function on the enabler function (onoffEl)
        function testOnOff(this)
            % TMP: Testing function on the enabler function (onoffEl)
            this.initialState = this.curState;
            
            this.getFlag = true(size(this.curState));
            this.getAllElContent();
            
            this.newState = true(size(this.curState));
            this.onoffUIEl(); drawnow;
            for i=1:8
                this.newState = randn(length(this.newState),1)>=0;
                this.onoffUIEl();
                drawnow;
            end
            tic;
            this.newState = false(size(this.curState));
            for i=1:length(this.curState)
               this.newState(i) = true;
               this.onoffUIEl();
               drawnow;
            end
            toc;
            
            tic;
            this.newState = true(size(this.curState));
            for i=1:length(this.curState)
               this.newState(i) = false;
               this.onoffUIEl();
               drawnow;
            end
            toc;
            this.newState = false(size(this.curState));
            this.newState([this.idUI.pMode this.idUI.lProcMode this.idUI.bExit]) = true;
            this.onoffUIEl();
            % pause(1);
            
            this.newState = this.initialState;
            this.onoffUIEl();
            this.setFlag = true(size(this.curState));
            this.setAllElContent();
            %pause(0.5);
            %this.disableAll();
        end
        
        % Contains OS specific modifiers for the interface, e.g. fontSize, fontName
        function setOSappearence(this)
            % Contains OS specific modifiers for the interface, e.g. fontSize, fontName
            % Increase font for Mac (retina)
            if ismac
                scale_factor = 1.4;
                font_size = get(this.id2handle(2:end),'FontSize');
                %set(this.id2handle(2:end),'FontName','Helvetica')
                
                for i = 2 : length(this.id2handle)
                    set(this.id2handle(i),'FontSize', font_size{i-1} * scale_factor);
                end
            end
        end
        
        % TMP: Testing function on the enabler function (onoffEl)
        function testFontSize(this, scale_factor)
            % TMP: Testing function on the enabler function (onoffEl)
            font_size = get(this.id2handle(2:end),'FontSize');
            for i = 3 : length(this.id2handle)
                set(this.id2handle(i),'FontSize', font_size{i-1} * scale_factor);
            end
        end
    end      
    
    %   GUI GETTERS
    % -------------------------------------------------------------------------
    % Functions that get specific statuses
    methods
        %   GETTERS
        % =================================================================
        
        function isI = isInitialized(this)
            % Return the status of initialization
            isI = this.initialized;
        end
            
        % Get the mode as integer value (note that this mode is the global identifier of the goGPS algorithm to be used
        function mode = getgoGPSMode(this)
            % Get the mode as integer value (note that this mode is the global identifier of the goGPS algorithm to be used
            if this.isRealTime()
                switch this.getElVal(this.idUI.lCaptMode)
                    case this.idNav
                        mode = goGNSS.MODE_RT_NAV;
                    case this.idRMon
                        mode = goGNSS.MODE_RT_R_MON;
                    case this.idMMon
                        mode = goGNSS.MODE_RT_M_MON;
                    case this.idRMMon
                        mode = goGNSS.MODE_RT_RM_MON;
                end
            elseif this.isPostProc()
                if this.isLS()
                    switch this.getElVal(this.idUI.lProcType)
                        case this.idC_SA
                            mode = goGNSS.MODE_PP_LS_C_SA;
                        case this.idC_DD
                            mode = goGNSS.MODE_PP_LS_C_DD;
                        case this.idCP_DD_L
                            mode = goGNSS.MODE_PP_LS_CP_DD_L;
						case this.idCP_Vel
                            mode = goGNSS.MODE_PP_LS_CP_VEL;
                        case this.idC_SA_MR
                            mode = goGNSS.MODE_PP_LS_C_SA_MR;
                        case this.idCP_DD_MR
                            mode = goGNSS.MODE_PP_LS_CP_DD_MR;
                    end
                end
                if this.isKF()
                    switch this.getElVal(this.idUI.lProcType)
                        case this.idC_SA
                            mode = goGNSS.MODE_PP_KF_C_SA;
                        case this.idC_DD
                            mode = goGNSS.MODE_PP_KF_C_DD;
                        case this.idCP_SA
                            mode = goGNSS.MODE_PP_KF_CP_SA;
                        case this.idCP_DD
                            mode = goGNSS.MODE_PP_KF_CP_DD;
                        case this.idCP_DD_MR
                            mode = goGNSS.MODE_PP_KF_CP_DD_MR;
                    end
                end
                
                if this.isSEID()
                    switch this.getElVal(this.idUI.lProcType)
                        case this.idSEID_RO
                            mode = goGNSS.MODE_PP_KF_CP_DD_MR;
                        case this.idSEID_PPP
                            mode = goGNSS.MODE_PP_SEID_PPP;
                    end
                end
            end
        end
        
        %   INTERFACE GETTERS - MODE
        % =================================================================
        
        % Get processing mode
        function isRT = isRealTime(this)
            % Get processing mode
            isOn = this.isEnabled(this.idUI.lProcMode);
            isRT = isOn && (this.getElVal(this.idUI.lProcMode) == this.idRealTime);
        end
        
        % Get monitor status
        function isMon = isMonitor(this)
            % Get monitor status
            isOn = this.isEnabled(this.idUI.lCaptMode);
            isMon = isOn && ~this.isCaptureMode(this.idNav);
        end
        
        % Get Post Processing status
        function isPP = isPostProc(this)
            % Get Post Processing status
            isOn = this.isEnabled(this.idUI.lProcMode);
            isPP = isOn && (this.getElVal(this.idUI.lProcMode) == this.idPostProc);
        end
        
        % Get capture mode
        function isCM = isCaptureMode(this, idCaptureMode)
            % Get capture mode
            isOn = this.isEnabled(this.idUI.lCaptMode);
            isCM = isOn && this.isRealTime() && (this.getElVal(this.idUI.lCaptMode) == idCaptureMode);
        end
        
        % Get algorithm type:
        function isLeastSquares = isLS(this)
            % return true if Least Squares
            isOn = this.isEnabled(this.idUI.lAlgType);
            isLeastSquares = isOn  && this.isPostProc() && (this.getElVal(this.idUI.lAlgType) == this.idLS);
        end
        function isKalman = isKF(this)
            % return true if Kalman
            isOn = this.isEnabled(this.idUI.lAlgType);
            isKalman = isOn && this.isPostProc() && (this.getElVal(this.idUI.lAlgType) == this.idKF);
        end
        function isSEID_L2 = isSEID(this)
            % return true if SEID
            isOn = this.isEnabled(this.idUI.lAlgType);
            isSEID_L2 = isOn && this.isPostProc() && (this.getElVal(this.idUI.lAlgType) == this.idSEID);
        end
        
        % Get processing type
        function isPT = isProcessingType(this, idProcessingType)
        % Get processing type
            isOn = this.isEnabled(this.idUI.lProcType);
            isPT = isOn && this.isPostProc() && (this.getElVal(this.idUI.lProcType) == idProcessingType);
        end
        
        function isSA = isStandAlone(this)
            % return true if Stand Alone
            isSA = this.isProcessingType(this.idC_SA) || (this.isLS() && this.isProcessingType(this.idCP_Vel)) || this.isPPP();
        end
        
        function isMR = isMultiReceiver(this)
            % return true if Multi Receiver
            isMR = this.isProcessingType(this.idC_SA_MR) || this.isProcessingType(this.idCP_DD_MR);
        end
        
        function isS_RO = isSEID_RO(this)
            % return true if SEID
            isOn = this.isEnabled(this.idUI.lProcType);
            isS_RO = isOn && this.isSEID() && this.isProcessingType(this.idSEID_RO);
        end

        function isS_PPP = isSEID_PPP(this)
            % return true if SEID + PPP
            isOn = this.isEnabled(this.idUI.lProcType);
            isS_PPP = isOn && this.isSEID() && this.isProcessingType(this.idSEID_PPP);
        end
        
        function is_KF_CP_SA = isPPP(this)
            % return true if PPP
            is_KF_CP_SA = (this.isKF() && this.isProcessingType(this.idCP_SA)) || this.isSEID_PPP();
        end

        %   INTERFACE GETTERS - INPUT FILE TYPE
        % =================================================================
        
        % Set a new password
        function pwd = getPassword(this)
            % Set a new password
            if isfield(this.goh,'jPassword')
                pwd = this.goh.jPassword.jpwd.getPassword();
            else
                pwd = '';
            end
        end
        
        % Get LAMBDA version
        function isLambda2 = isLambda2(this)
            % return true if LAMBDA version = 2
            isOn = this.isEnabled(this.idUI.lLAMBDAMethod);
            isLambda2 = isOn && (this.getElVal(this.idUI.lLAMBDAMethod) == this.idILS_enum_old);
        end
        function isLambda3Par = isLambda3Par(this)
            % return true if LAMBDA version = 3
            isOn = this.isEnabled(this.idUI.lLAMBDAMethod);
            isLambda3Par = isOn && (this.getElVal(this.idUI.lLAMBDAMethod) == this.idPAR);
        end
        function isLambdaIls = isLambdaIls(this)
            % return true if LAMBDA Ils
            isOn = this.isEnabled(this.idUI.lLAMBDAMethod);
            isLambdaIls = isOn && ((this.getElVal(this.idUI.lLAMBDAMethod) == this.idILS_enum_old) || ...
                (this.getElVal(this.idUI.lLAMBDAMethod) == this.idILS_shrink)   || ...
                (this.getElVal(this.idUI.lLAMBDAMethod) == this.idILS_enum));
        end
        
        % Get dynamic model
        function isStatic = isDynModelStatic(this)
            % Get dynamic model
            isOn = this.isEnabled(this.idUI.lDynModel);
            isStatic = isOn && (this.getElVal(this.idUI.lDynModel) == this.idStatic);
        end
    end
    
    %   GUI SETTERS
    % -------------------------------------------------------------------------
    % Functions that set specific statuses
    methods
        % Set a new password
        function setPassword(this, password)
            % Set a new password
            
            if isfield(this.goh,'jPassword')
                try
                    eval(sprintf('this.goh.jPassword.jpwd.setText(''%s'')',password));
                catch
                end
            elseif (this.isInitialized())
                set(this.goh.password,'String',password);
            end
        end
                
        % Modify the password
        function modifyPassword(this, newkey, newchar)
        % Modify the password (disabled)
%             password = this.getPassword();
%             switch newkey
%                 case 'backspace'
%                     password = password(1:end-1); % Delete the last character in the password
%                 case 'delete'
%                     password = password(2:end); % Delete the first character in the password
%                 otherwise
%                     % If pressed key produces a printable character
%                     if (uint8(newchar) > 32)
%                         password = [password newchar]; % Add the typed character to the password
%                         pause(0.001)%to avoid unwanted character output before the cursor
%                     end
%             end
%             
%             this.setPassword(password); % Store the password in its current state
        end
        
        % Show the password in the password field
        function showPassword(this)
            % Show the password in the password field
            if isfield(this.goh,'jPassword')
                if this.isActive(this.idUI.bUPass)
                    this.goh.jPassword.jpwd.setEchoChar(char(0));
                else
                    this.goh.jPassword.jpwd.setEchoChar(this.echoChar);
                end
            end
        end

    end
    
    %   GUI EVENT MENAGEMENT
    % -------------------------------------------------------------------------
    % Functions that manage events main callers
    methods
        % Function that runs inside onoffUIEl
        % Test every logical dependence in the GUI
        % E.g. a flag that activate other fields
        function checkUIdependencies(this)
            % Test every logical dependence in the GUI
                        
          %   INPUT FILE TYPE
          % --------------------------------------------------------------- 

            % Check File input dependencies
            this.setElStatus([this.idGroup.onRin], 1, 0);
            if (this.isStandAlone() && not(this.isSEID))
                this.setElStatus([this.idGroup.RinMaster], 0, 0);
            end
            
            % Set Labels for I/O files
            if this.isSEID()
                this.setGuiElStr(this.id2handle(this.idUI.tRinRover),this.str_source_rover{1});
                this.setGuiElStr(this.id2handle(this.idUI.tRinMaster),this.str_target_master{1});
            else
                this.setGuiElStr(this.id2handle(this.idUI.tRinRover),this.str_source_rover{2});
                this.setGuiElStr(this.id2handle(this.idUI.tRinMaster),this.str_target_master{2});                
            end
            
            
          %   DATA USAGE
          % --------------------------------------------------------------- 

            if (length(this.getFreq()) > 1) && (this.isPPP() || (this.isLS && this.isStandAlone))
                this.setElStatus(this.idGroup.pObsComb, 1, 0);
            else
                this.setElStatus(this.idGroup.pObsComb, 0, 0);
            end
            
            % Ocean loading toggle
            isOn = this.isActive(this.idUI.cOcean);
            this.setElStatus([this.idGroup.BLQ], isOn, 0);

                        
          %   OPTIONS
          % --------------------------------------------------------------- 

            % Reference path file
            isOn = this.isActive(this.idUI.cRefPath);
            this.setElStatus([this.idGroup.RefPath], isOn, 0);
            this.setElStatus([this.idUI.cConstraint], isOn, 0);
            
            % Plot while processing flag
            isOn = this.isActive(this.idUI.cPlotProc);
            this.setElStatus([this.idGroup.gPlotProc], isOn, 0);
            
            % If the master is not available disable the flag to plot it 
            if ~this.isEnabled(this.idUI.fRinMaster)
                this.setElStatus([this.idUI.cPlotMaster], 0, 0);
            end
            
            % If only code is used, no ambiguities are available
            if this.isProcessingType(this.idC_SA) || this.isProcessingType(this.idC_DD)
                this.setElStatus([this.idUI.cPlotAmb], 0, 0);
            end

            % Only for the variometric approach google Earth plot is disabled
            if this.isLS() && this.isProcessingType(this.idCP_Vel)
                this.setElStatus([this.idUI.cGEarth], 0, 0);
            end
            
            % NTRIP flag
            isOn = this.isActive(this.idUI.cUseNTRIP);
            this.setElStatus([this.idGroup.gNTRIP], isOn, 0);
            
          %   INTEGER AMBIGUITY RESOLUTION
          % --------------------------------------------------------------- 
          
            % LAMBDA flag
            isOn = this.isActive(this.idUI.cLAMBDA);
            this.setElStatus([this.idGroup.gLAMBDA], isOn, 0);

            % LAMBDA version check
            if (this.isLambda2())
                this.setElStatus([this.idGroup.gLAMBDA3], 0, 0);
            end
            if (~this.isLambdaIls())
                this.setElStatus([this.idGroup.gLAMBDAILS], 0, 0);
                if (this.isLambda3Par())
                    this.setElStatus([this.idUI.tP0], 1, 0);
                    this.setElStatus([this.idUI.nP0], 1, 0);
                    this.setElStatus([this.idUI.cP0], 1, 0);
                end
            end
            
            if (this.isLambda3Par())
                set(this.goh.tP0,'String','Min. success rate (P0):');
            else
                set(this.goh.tP0,'String','Fixed failure rate (P0):');
            end

            % Automatic mu flag
            isOn = this.isEnabled(this.idUI.cMu) && this.isActive(this.idUI.cMu);
            if (isOn)
                this.setElStatus([this.idUI.nMu], ~isOn, 0);
            end
            
            % Default P0 flag
            isOn = this.isEnabled(this.idUI.cP0) && this.isActive(this.idUI.cP0);
            if (isOn)
                this.setElStatus([this.idUI.nP0], ~isOn, 0);
            end

          %   SETTINGS - KALMAN FILTER - STD
          % --------------------------------------------------------------- 

            % Error standard deviation Phase
            isOn = this.isActive(this.idUI.bStdPhase);
            this.setElStatus([this.idUI.nStdPhase], isOn, 0);
            this.setElStatus([this.idUI.uStdPhase], isOn, 0);
            
            % DTM toggle
            isOn = this.isActive(this.idUI.bStdDTM);
            this.setElStatus([this.idGroup.gDTM], isOn, 0);

          %   SETTINGS - KALMAN FILTER
          % --------------------------------------------------------------- 

            % Stop Go Stop
            if this.isEnabled(this.idUI.cStopGoStop)
                isOn = this.isActive(this.idUI.cStopGoStop);
                this.setElStatus(this.idGroup.pDynModel, ~isOn, 0);
            end
            
            if this.isPPP()
                this.setElVal(this.idUI.lARAA, 1+1, 0);
            end
                        
          %   SETTINGS - PORTS
          % ---------------------------------------------------------------

            % Ports
            if this.isEnabled(this.idUI.lnPorts)
                nPorts = this.getElVal(this.idUI.lnPorts);
                this.setElStatus([this.idGroup.lPort0], nPorts > 0, 0); nPorts = nPorts-1;
                this.setElStatus([this.idGroup.lPort1], nPorts > 0, 0); nPorts = nPorts-1;
                this.setElStatus([this.idGroup.lPort2], nPorts > 0, 0); nPorts = nPorts-1;
                this.setElStatus([this.idGroup.lPort3], nPorts > 0, 0);
            end
            
          %   SETTINGS - KALMAN FILTER - DYNAMIC MODEL
          % ---------------------------------------------------------------

            this.resetDynModel();
            
            % Check if static dynamic model
            if (this.isDynModelStatic())
                this.setElStatus([this.idGroup.pKF_ENU], 0, 0);                
            else
                if (this.isKF() || this.isSEID_PPP())
                    this.setElStatus([this.idGroup.pKF_ENU], 1, 0);
                end
            end 
            
            if ~this.isMonitor()
                switch this.getElVal(this.idUI.lDynModel)
                    case this.idCVel, this.setGuiElStr(this.id2handle(this.idUI.uStdENU),'m/s');
                    case this.idCAcc, this.setGuiElStr(this.id2handle(this.idUI.uStdENU),'m/s^2');
                    case this.idStatic, this.setGuiElStr(this.id2handle(this.idUI.uStdENU),'m');
                    case this.idVariable, this.setGuiElStr(this.id2handle(this.idUI.uStdENU),'m');
                end
            end

                
          %   SETTINGS - MASTER STATION
          % ---------------------------------------------------------------
            if this.isEnabled(this.idUI.cMPos)
                % If the panel is enabled
                isOn = this.isActive(this.idUI.cMPos);
                % if isOn the rest should be disabled
                this.setElStatus(this.idUI.lCRS, ~isOn, 0);                
                isXYZ = this.getElVal(this.idUI.lCRS) == this.idXYZ;
                this.setElStatus([this.idGroup.gMXYZ], isXYZ && ~isOn, 0);
                this.setElStatus([this.idGroup.gMGeodetic], ~isXYZ && ~isOn, 0);                
            else
                this.setElStatus([this.idGroup.pMSt], 0, 0);
            end

            
          %   SETTINGS - MASTER SERVER
          % ---------------------------------------------------------------
            
            % Password
            this.showPassword();
            
          %   MODE
          % --------------------------------------------------------------- 
            
          %  % Check list boxes
          %  isOn = this.isRealTime();
          %  this.setElStatus([this.idUI.lCaptMode], isOn, 0);
          %  this.setElStatus([this.idUI.lAlgType this.idUI.lProcType], ~isOn, 1);
            
          %   GO BUTTON AND LEDS
          % --------------------------------------------------------------- 
          % For each file field enabled, I have to check the existence of
          % the folder / file to enable the go Button
            this.onoffUIEl();
            this.updateLEDstate();
            goOk = this.test4Go();
            this.setElStatus([this.idUI.bSave this.idUI.bGo] , goOk, 1);
        end
        
        % Force INI update
        function forceINIupdate(this)
            % Force INI update
            this.updateLEDstate(true);
            goOk = this.test4Go();
            this.setElStatus([this.idUI.bSave this.idUI.bGo] , goOk, 1);
        end
        
        % EVENT MANAGER
        % When an element is modified (and launch a callback function in
        % the GUI) this function must be called!
        function syncFromGUI(this, idEl)
            % Sync the internal copy of the interface with the GUI
            if (nargin == 1)
                idEl = this.idUI.lProcMode;
            end
            this.getFlag(idEl) = true;
            % Read all the values of the elements
            this.getAllElContent();
            this.setAllElContent();

          %   MODE
          % --------------------------------------------------------------- 
            if sum(intersect(idEl, this.idUI.lProcMode)) > 0
                if this.isRealTime()
                    this.setElStatus(this.idUI.lCaptMode, 1, 0);
                    % Trigger the next popup menu
                    idEl = unique([idEl this.idUI.lCaptMode]);
                else
                    this.setElStatus([this.idUI.lAlgType], 1, 0);
                    % Trigger the next popup menu
                    idEl = unique([idEl this.idUI.lAlgType]);
                end
            end
            
            % I'm in real time, and this popup menu is active
            if sum(intersect(idEl, this.idUI.lCaptMode)) > 0
                if this.isRealTime()
                    this.setElStatus(this.idGroup.Fig, 0, 0);
                    switch this.getElVal(this.idUI.lCaptMode)
                        case this.idNav
                            this.setElStatus(this.idGroup.onRT_Nav, 1, 0);
                        case this.idRMon
                            this.setElStatus(this.idGroup.onRT_RMon, 1, 0);
                        case this.idMMon
                            this.setElStatus(this.idGroup.onRT_MMon, 1, 0);
                        case this.idRMMon
                            this.setElStatus(this.idGroup.onRT_RMMon, 1, 0);
                    end
                end
                this.updateGUI();
            end
            
            % I'm in post processing and these popup menus are active
            if sum(intersect(idEl, this.idUI.lAlgType)) > 0
                this.initProcessingType();
                this.getFlag(this.idUI.lProcType) = true;
                this.setElStatus([this.idUI.lProcType], 1, 0);
                % Trigger the next popup menu
                idEl = unique([idEl this.idUI.lProcType]);
                this.getAllElContent();
            end        
            
            if sum(intersect(idEl, this.idUI.lProcType)) > 0
                % Enable / Disable elements
                if this.isPostProc()
                    if this.isLS()
                        this.setElStatus(this.idGroup.Fig, 0, 0);
                        switch this.getElVal(this.idUI.lProcType)
                            case this.idC_SA
                                this.setElStatus(this.idGroup.onPP_LS_C_SA, 1, 0);
                            case this.idC_DD
                                this.setElStatus(this.idGroup.onPP_LS_C_DD, 1, 0);
                            case this.idCP_DD_L
                                this.setElStatus(this.idGroup.onPP_LS_CP_DD_L, 1, 0);
                            case this.idCP_Vel
                                this.setElStatus(this.idGroup.onPP_LS_CP_Vel, 1, 0);
                            case this.idC_SA_MR
                                this.setElStatus(this.idGroup.onPP_LS_C_SA_MR, 1, 0);
                            case this.idCP_DD_MR
                                this.setElStatus(this.idGroup.onPP_LS_CP_DD_MR, 1, 0);
                        end
                    end
                    if this.isKF()
                        this.setElStatus(this.idGroup.Fig, 0, 0);
                        switch this.getElVal(this.idUI.lProcType)
                            case this.idC_SA
                                this.setElStatus(this.idGroup.onPP_KF_C_SA, 1, 0);
                            case this.idC_DD
                                this.setElStatus(this.idGroup.onPP_KF_C_DD, 1, 0);
                            case this.idCP_SA
                                this.setElStatus(this.idGroup.onPP_KF_CP_SA, 1, 0); % PPP
                            case this.idCP_DD
                                this.setElStatus(this.idGroup.onPP_KF_CP_DD, 1, 0);
                            case this.idCP_DD_MR                                
                                this.setElStatus(this.idGroup.onPP_KF_CP_DD_MR, 1, 0);
                        end
                    end
                    
                    % PPP for SEID
                    if this.isSEID()
                        this.setElStatus(this.idGroup.Fig, 0, 0);
                        this.setElStatus(this.idGroup.onPP_SEID_PPP, 1, 0);
                    end

                    this.getFlag(idEl) = true;
                    this.updateGUI();
                end
                
                % Verify if there's still something to enable/disable
                this.onoffUIEl();
                % Check dependencies
                this.checkUIdependencies();
            end         
            
          %   INPUT/OUTPUT FILE AND FOLDERS
          % ---------------------------------------------------------------

            % Browse for rover file
            if sum(intersect(idEl, this.idUI.bINI)) > 0
                this.browseINIFile();
            end
            if sum(intersect(idEl, this.idGroup.gINI)) > 0
                this.forceINIupdate();
            end
                
            % Browse output foder fo binary data
            if sum(intersect(idEl, this.idUI.bDirGoOut)) > 0
                this.browseOutDir()
            end

          %   SETTINGS - MASTER STATION
          % ---------------------------------------------------------------

            % Toggle show password
            if sum(intersect(idEl, this.idUI.bUPass)) > 0
                this.showPassword();
            end

            
          %   BUTTONS
          % ---------------------------------------------------------------
                        
            % on Load Settings
            if sum(intersect(idEl, this.idUI.bLoad)) > 0
                this.loadState();
            end
            
            % on Save Settings
            if sum(intersect(idEl, this.idUI.bSave)) > 0
                this.saveState();
            end
            
            % on GO
            if sum(intersect(idEl, this.idUI.bGo)) > 0
                this.go();
            end
            
            this.onoffUIEl();
            this.checkUIdependencies();
            
            % on Exit
            if sum(intersect(idEl, this.idUI.bExit)) > 0
                if isfield(this.goh, 'main_panel');
                    close(this.goh.main_panel);
                else % Something went wrong in the initialization phase
                    close(gcf);
                end
            end
        end
    end
    
    %   GUI EVENT MENAGEMENT - AUXILIAR FUNCTIONS
    % -------------------------------------------------------------------------
    % Functions that manage events - auxiliar functions
    methods
        % Test if the active file/dir paths contain valid file/dir
        function updateLEDstate(this, force)
            % Test if the active file/dir paths contain valid file/dir
            global goIni
            if nargin == 1
                force = 0;      % force file update
            end
            
            % Check INI file
            if this.isEnabled(this.idUI.sINI)
                file_name = checkPath(this.getElVal(this.idUI.sINI));
                
                if isempty(file_name)
                    this.setGUILedStatus(this.idUI.fINI, this.ledKo, 0);
                    % If I do not have an INI file, every LED should be RED
                    for  i = 1:length(this.idGroup.gInINILED)
                        this.setGUILedStatus(this.idGroup.gInINILED(i), this.ledKo, 0);
                    end
                else
                    if exist(file_name,'file')
                        this.setGUILedStatus(this.idUI.fINI, this.ledOk, 0);
                        
                        if this.isPostProc()
                            % If needed init INI reader
                            if isempty(goIni)
                                goIni = Go_Ini_Manager(file_name);                                
                            end
                            if (~goIni.getReadStatus())
                                goIni.readFile();
                            end
                            % If I have to update the ini file
                            goIni.update(file_name, force);
                            % Receivers file --------------------------------------
                            nR = goIni.getData('Receivers','nRec');
                            data_path = checkPath(goIni.getData('Receivers','data_path'));
                            file_name = goIni.getData('Receivers','file_name');
                            
                            if (isempty(nR))
                                if iscell(file_name)
                                    nR = length(file_name);
                                else
                                    nR = 1;
                                end
                                goIni.addKey('Receivers','nRec',nR);
                            end
                            this.setElVal(this.idUI.tNumRec,['x ' num2str(nR)]);
                            
                            if (isempty(data_path))
                                data_path = '';
                            end
                            if (isempty(file_name))
                                this.setGUILedStatus(this.idUI.fRinRover, this.ledKo, 0);
                            else
                                % If I have more than one receiver
                                if iscell(file_name)
                                    % The number of receiver is = to the number of files?
                                    if nR ~= length((file_name))   % DeclaRED number of file ~= number of files
                                        this.setGUILedStatus(this.idUI.fRinRover, this.ledCk, 0);
                                    else
                                        % Check the presence of all the files
                                        fileOk = true;
                                        for r = 1:nR
                                            if ~exist([data_path file_name{r}],'file')
                                                fileOk = false;
                                            end
                                        end
                                        if fileOk
                                            this.setGUILedStatus(this.idUI.fRinRover, this.ledOk, 0);
                                        else
                                            this.setGUILedStatus(this.idUI.fRinRover, this.ledCk, 0);
                                        end
                                    end
                                else
                                    % The number of receiver is = to the number of files?
                                    if nR > 1   % DeclaRED number of file ~= number of files
                                        this.setGUILedStatus(this.idUI.fRinRover, this.ledCk, 0);
                                    else
                                        % Check the presence of all the files
                                        if exist([data_path file_name],'file')
                                            this.setGUILedStatus(this.idUI.fRinRover, this.ledOk, 0);
                                        else
                                            this.setGUILedStatus(this.idUI.fRinRover, this.ledCk, 0);
                                        end
                                    end
                                end
                            end
                            
                            % Master file -----------------------------------------
                            data_path = checkPath(goIni.getData('Master','data_path'));
                            file_name = goIni.getData('Master','file_name');
                            if (isempty(data_path))
                                data_path = '';
                            end
                            if (isempty(file_name))
                                this.setGUILedStatus(this.idUI.fRinMaster, this.ledKo, 0);
                            else
                                % Check the presence of all the files
                                if exist([data_path file_name],'file')
                                    this.setGUILedStatus(this.idUI.fRinMaster, this.ledOk, 0);
                                else
                                    this.setGUILedStatus(this.idUI.fRinMaster, this.ledCk, 0);
                                end
                            end
                            
                            % Navigation file -------------------------------------
                            data_path = checkPath(goIni.getData('Navigational','data_path'));
                            file_name = goIni.getData('Navigational','file_name');
                            if (isempty(data_path))
                                data_path = '';
                            end
                            if (isempty(file_name))
                                this.setGUILedStatus(this.idUI.fRinNav, this.ledKo, 0);
                            else
                                % Check the presence of all the files
                                if exist([data_path file_name],'file')
                                    this.setGUILedStatus(this.idUI.fRinNav, this.ledOk, 0);
                                else
                                    this.setGUILedStatus(this.idUI.fRinNav, this.ledCk, 0);
                                end
                            end
                                                        
                            % DTM file -----------------------------------------------
                            data_path = checkPath(goIni.getData('DTM','data_path'));
                            if (isempty(data_path))
                                this.setGUILedStatus(this.idUI.fDTM, this.ledKo, 0);
                            else
                                % Check the presence of the directory
                                if exist(data_path,'dir')
                                    this.setGUILedStatus(this.idUI.fDTM, this.ledOk, 0);
                                else
                                    this.setGUILedStatus(this.idUI.fDTM, this.ledCk, 0);
                                end
                            end
                            
                            % Reference path file ------------------------------------
                            data_path = checkPath(goIni.getData('RefPath','data_path'));
                            file_name = goIni.getData('RefPath','file_name');
                            if (isempty(data_path))
                                data_path = '';
                            end
                            if (isempty(file_name))
                                this.setGUILedStatus(this.idUI.fRefPath, this.ledKo, 0);
                            else
                                % Check the presence of all the files
                                if exist([data_path file_name],'file')
                                    this.setGUILedStatus(this.idUI.fRefPath, this.ledOk, 0);
                                else
                                    this.setGUILedStatus(this.idUI.fRefPath, this.ledCk, 0);
                                end
                            end
                            
                            % PCO/PCV file ------------------------------------
                            data_path = checkPath(goIni.getData('PCO_PCV_file','data_path'));
                            file_name = goIni.getData('PCO_PCV_file','file_name');
                            if (isempty(data_path))
                                data_path = '';
                            end
                            if (isempty(file_name))
                                this.setGUILedStatus(this.idUI.fPCO, this.ledOp, 0);
                            else
                                % Check the presence of all the files
                                if exist([data_path file_name],'file')
                                    this.setGUILedStatus(this.idUI.fPCO, this.ledOk, 0);
                                else
                                    this.setGUILedStatus(this.idUI.fPCO, this.ledCk, 0);
                                end
                            end
                            
                            % OCEAN LOADING file ------------------------------------
                            data_path = checkPath(goIni.getData('OCEAN_LOADING_file','data_path'));
                            file_name = goIni.getData('OCEAN_LOADING_file','file_name');
                            if (isempty(data_path))
                                data_path = '';
                            end
                            if (isempty(file_name))
                                this.setGUILedStatus(this.idUI.fBLQ, this.ledOp, 0);
                            else
                                % Check the presence of all the files
                                if exist([data_path file_name],'file')
                                    this.setGUILedStatus(this.idUI.fBLQ, this.ledOk, 0);
                                else
                                    this.setGUILedStatus(this.idUI.fBLQ, this.ledCk, 0);
                                end
                            end
                            
                            % STATIONS file ------------------------------------
                            data_path = checkPath(goIni.getData('STATIONS_file','data_path'));
                            file_name = goIni.getData('STATIONS_file','file_name');
                            if (isempty(data_path))
                                data_path = '';
                            end
                            if (isempty(file_name))
                                this.setGUILedStatus(this.idUI.fSTA, this.ledOp, 0);
                            else
                                % Check the presence of all the files
                                if exist([data_path file_name],'file')
                                    this.setGUILedStatus(this.idUI.fSTA, this.ledOk, 0);
                                else
                                    this.setGUILedStatus(this.idUI.fSTA, this.ledCk, 0);
                                end
                            end
                        end
                    else
                        this.setGUILedStatus(this.idUI.fINI, this.ledCk, 0);
                        % If I do not have an INI file, every LED should be RED
                        for  i = 1:length(this.idGroup.gInINILED)
                            this.setGUILedStatus(this.idGroup.gInINILED(i), this.ledKo, 0);
                        end
                    end
                end
            end
            
          % Output dir --------------------------------------------------------
            
          outDir = this.getElVal(this.idUI.sDirGoOut);
          outDir = checkPath(outDir);
          if isempty(outDir)
              this.setGUILedStatus(this.idUI.fDirGoOut, this.ledKo, 0);
          else
              if ~exist(outDir,'dir');
                  this.setGUILedStatus(this.idUI.fDirGoOut, this.ledCk, 0);
              else
                  this.setGUILedStatus(this.idUI.fDirGoOut, this.ledOk, 0);
              end
          end
            
        end        
        
        % Test if all the folder / files are ok and it is possible to activate go and save buttons
        function goOk = test4Go(this)
            % Test if all the folder / files are ok and it is possible to activate go and save buttons
            goOk = 0;
            % Performs all the led check before allowing the launch... ehm
            % activation of the Go! button
            if this.isPostProc()
                for i = 1:length(this.idGroup.gLED)
                    goOk = goOk+this.okGo(this.idGroup.gLED(i));
                end
                goOk = (goOk - length(this.idGroup.gLED)) == 0;
            else % In real time I just have to check for the output folder
                goOk = this.okGo(this.idUI.fDirGoOut) == 1;
            end
            
            % Chek constellations to be used
            % I need at least one of these constellation active
            activeGNSS        = [this.isActive(this.idUI.cGPS) ...
                                 this.isActive(this.idUI.cGLONASS) ...
                                 this.isActive(this.idUI.cGalileo) ...
                                 this.isActive(this.idUI.cBeiDou) ...
                                 this.isActive(this.idUI.cQZSS)];
            if sum(activeGNSS) == 0
                this.setElVal(this.idUI.cGPS, true, 0);
                % goOk = 0;
            end
            
            % get the available freq but also check for validity
            this.getFreq();
        end
        
        % Browse INI file
        function browseINIFile(this)
            % Browse INI file
            % In multi receiver mode, I read from ini file
            config_dir = this.state.prj_home;
            if exist([config_dir filesep 'config'], 'dir')
                config_dir = [config_dir filesep 'config'];
            else
                config_dir = this.getSettingsDir();
            end
            [file_name, pathname] = uigetfile( ...
                {'*.ini;','INI configuration file (*.ini)'; ...
                '*.*',  'All Files (*.*)'}, ...
                'Choose an INI configuration file', config_dir);
            if (file_name ~= 0)
                this.setElVal(this.idUI.sINI, fullfile(pathname, file_name));
            end
            this.updateGUI();
        end
        
        % Browse for rover file
        function browseRoverObsFile(this)
            % Browse for rover file
            if this.isPostProc() && (this.getElVal(this.idUI.lProcType) == this.idCP_DD_MR)
                % In multi receiver mode, I read from ini file
                [file_name, pathname] = uigetfile( ...
                    {'*.ini;','INI configuration file (*.ini)'; ...
                    '*.*',  'All Files (*.*)'}, ...
                    'Choose an INI configuration file',[this.getSettingsDir()]);                
            else
                [file_name, pathname] = uigetfile( ...
                    {'*.obs;*.??o;*.??O','RINEX observation files (*.obs,*.??o,*.??O)';
                    '*.obs','Observation files (*.obs)'; ...
                    '*.??o;*.??O','Observation files (*.??o,*.??O)'; ...
                    '*.*',  'All Files (*.*)'}, ...
                    'Choose a RINEX observation file for the rover',[this.getWorkingDir() 'data_RINEX']);
            end
            if (file_name ~= 0)
                this.setElVal(this.idUI.sRinRover, fullfile(pathname, file_name));
            end
            this.updateGUI();
        end
        
        % Browse for a master file
        function browseMasterObsFile(this)
            % Browse for a master file
            [file_name, pathname] = uigetfile( ...
                {'*.obs;*.??o','RINEX observation files (*.obs,*.??o)';
                '*.obs','Observation files (*.obs)'; ...
                '*.??o','Observation files (*.??o)'; ...
                '*.*',  'All Files (*.*)'}, ...
                'Choose a RINEX observation file for the master',[this.getWorkingDir() 'data_RINEX']);
            
            if (file_name ~= 0)
                this.setElVal(this.idUI.sRinMaster, fullfile(pathname, file_name));
            end
            this.updateGUI();
        end
        
        % Browse for a navigation file
        function browseNavigationFile(this)
            % Browse for a navigation file
            [file_name, pathname] = uigetfile( ...
                {'*.nav;*.??n;*.??N','RINEX navigation files (*.nav,*.??n,*.??N)';
                '*.nav','Navigation files (*.nav)'; ...
                '*.??n;*.??N','Navigation files (*.??n,*.??N)'; ...
                '*.*',  'All Files (*.*)'}, ...
                'Choose a RINEX navigation file',[this.getWorkingDir() 'data_RINEX']);
            
            if (file_name ~= 0)
                this.setElVal(this.idUI.sRinNav, fullfile(pathname, file_name));
            end
            this.updateGUI();
        end               
        
        % Browse output foder fo binary data
        function browseOutDir(this)
            % Browse output foder fo binary data
            dname = uigetdir(this.getWorkingDir(),'Choose a directory to store goGPS data');
            if (dname ~= 0)
                this.setElVal(this.idUI.sDirGoOut, dname);
            end
            this.updateGUI();
        end
        
        % Browse for a DTM folder
        function browseDtmDir(this)
            % Browse for a DTM folder
            dname = uigetdir([this.getWorkingDir() 'dtm'],'Choose a directory containing DTM data');
            if (dname ~= 0)
                this.setElVal(this.idUI.sDTM, dname);
            end
            this.updateGUI();
        end
        
        % Browse for the path containing reference points for constrained solutions
        function browseRefFile(this)
            % Browse for the path containing reference points for constrained solutions
            [file_name, pathname] = uigetfile('*.mat', 'Choose file containing reference path','../data');
            
            if (file_name ~= 0)
                this.setElVal(this.idUI.sRefPath, fullfile(pathname, file_name));
            end
            this.updateGUI();
        end
        
        % Led status
        % Set GREEN / RED status of the UI and optionally lock the UI
        % -------------------------------------------------------------------------
        function setGUILedStatus(this, idEl, status, autoapply)
            % Set GREEN / RED status of the UI and optionally lock the UI
            if nargin == 3
                autoapply = true;
            end
            
            if (status == this.ledOk)    % Led Ok
                if ~this.isColor(idEl, this.GREEN)
                    this.setElVal(idEl,this.GREEN)
                end
            elseif (status == this.ledKo) % Led Ko
                if ~this.isColor(idEl, this.RED)
                    this.setElVal(idEl,this.RED)
                end
            elseif (status == this.ledCk) % Led Check
                if ~this.isColor(idEl, this.YELLOW)
                    this.setElVal(idEl,this.YELLOW)
                end
            elseif (status == this.ledOp) % Led Optional parameter
                if ~this.isColor(idEl, this.BLUE)
                    this.setElVal(idEl,this.BLUE)
                end
            end
            this.setAllElContent();
            %this.setElStatus(idEl, status > 1, autoapply)
        end
        
    end
    
    %   IMPORT /EXPORT SETTINGS
    % -------------------------------------------------------------------------
    % Functions to load save settings from file        
    methods
        function loadState(this)
            % Load state settings
            
            config_dir = this.state.prj_home;
            if exist([config_dir filesep 'config'], 'dir')
                config_dir = [config_dir filesep 'config'];
            end
            [file_name, pathname] = uigetfile({'*.ini;','INI configuration file (*.ini)'; '*.mat;','state file goGPS < 0.5 (*.mat)'}, 'Choose file with saved settings', config_dir);
            
            if pathname == 0 % if the user pressed cancelled, then we exit this callback
                return
            end
            
            % get the extension (mat/ini):
            [path_str, name, ext] = fileparts(file_name);
                        
            % construct the path name of the file to be loaded
            loadDataName = fullfile(pathname,file_name);
            
            if strcmp(ext, '.mat')
                this.state.importLegacyFile(loadDataName);
                % load the settings, which creates a new gui
                this.importSettings(this.state);
                this.state.updatePrj(loadDataName);
            elseif strcmp(ext, '.ini')
                this.state.importIniFile(loadDataName);
                this.importSettings(this.state);                
            else
                this.logger.addError('Unrecognized input file format!');
            end
            
        end
        
        function saveState(this)
            % Save state settings
            config_dir = this.state.prj_home;
            if exist([config_dir filesep 'config'], 'dir')
                config_dir = [config_dir filesep 'config'];
            end
            [file_name,pathname] = uiputfile('*.ini','Save your GUI settings', config_dir);
            
            if pathname == 0 %if the user pressed cancelled, then we exit this callback
                return
            end
            %construct the path name of the save location
            saveDataName = fullfile(pathname,file_name);
            
            %saves the gui data
            this.state.setFilePath(saveDataName);
            this.exportStateMatlab(saveDataName);
        end
        
        % Load the state of the gui from a settings object
        function importSettings(this, state)
            % Load the state of the gui from a settings object
            % SYNTAX: this.importStateMatlab(<settings>)
            if (nargin == 1)
                state = this.state;
            end            
            
            %   MODE
            % ===============================================================
            
            [mode, nav_mon, ls_kalman, code_dd_sa] = state.getGuiMode();            

            this.setElVal(this.idUI.lProcMode, max(1,mode), 0);            
            this.initCaptureMode();
            this.setElVal(this.idUI.lCaptMode, max(1,nav_mon), 0);
            this.initAlgorithmType();
            this.setElVal(this.idUI.lAlgType, max(1,ls_kalman), 0);
            this.initProcessingType();
            this.setElVal(this.idUI.lProcType, max(1,code_dd_sa), 0);
            
            this.setElVal(this.idUI.cTropo, state.flag_tropo, 0);
            
            %   DATA SELECTION
            % ===============================================================
            
            this.setElVal(this.idUI.cL1, state.cc.list.GPS.flag_f(1), 0);
            this.setElVal(this.idUI.cL2, state.cc.list.GPS.flag_f(2), 0);
            this.setElVal(this.idUI.cL5, state.cc.list.GPS.flag_f(3), 0);
            this.setElVal(this.idUI.cL6, state.cc.list.GAL.flag_f(5), 0);
            
            rates = this.UI_P_SRATE;
            id = find(ismember(rates, state.p_rate));
            if isempty(id)
                id = 1;
            end
            
            this.setElVal(this.idUI.lProcRate, max(1, id), 0);

            this.setElVal(this.idUI.lObsComb, state.flag_ionofree + 1, 0);
            
            this.setElVal(this.idUI.nCutOff, num2str(state.cut_off,'%g'), 0);
            this.setElVal(this.idUI.nSNR, num2str(state.snr_thr,'%g'), 0);
            this.setElVal(this.idUI.nMinNSat, num2str(state.min_n_sat,'%g'), 0);
            this.setElVal(this.idUI.nMinArc, num2str(state.min_arc,'%g'), 0);

            %   OUTLIER DETECTION
            % ===============================================================
            
            this.setElVal(this.idUI.cOutlier, state.flag_outlier, 0);
            this.setElVal(this.idUI.nSPPthr, num2str(state.pp_spp_thr,'%g'), 0);
            this.setElVal(this.idUI.nCodeThr, num2str(state.pp_max_code_err_thr,'%g'), 0);
            this.setElVal(this.idUI.nPhaseThr, num2str(state.pp_max_phase_err_thr,'%g'), 0);
            
            %   OPTIONS
            % ===============================================================
            
            this.setElVal(this.idUI.cPrePro, state.flag_pre_pro, 0);
            this.setElVal(this.idUI.cMPos, state.flag_rinex_mpos, 0);
            this.setElVal(this.idUI.cConstraint, state.constrain, 0);
            this.setElVal(this.idUI.cPlotProc, state.plot_proc, 0);
            this.setElVal(this.idUI.cRefPath, state.plot_ref_path, 0);
            this.setElVal(this.idUI.cSkyPlot, ~state.plot_skyplot_snr, 0);
            this.setElVal(this.idUI.cGEarth, state.plot_google_earth, 0);
            this.setElVal(this.idUI.cErrEllipse, state.plot_err_ellipse, 0);
            this.setElVal(this.idUI.cPlotMaster, state.plot_master, 0);
            this.setElVal(this.idUI.cPlotAmb, state.plot_ambiguities, 0);
            this.setElVal(this.idUI.cUseNTRIP, state.flag_ntrip, 0);
            this.setElVal(this.idUI.cDoppler, state.flag_doppler, 0);
            
            this.setElVal(this.idUI.cOcean, state.flag_ocean, 0);
            % Temporary check in the migration to SBAS use period
            ss_list = state.cc.list;
            this.setElVal(this.idUI.cUse_SBAS, state.cc.list.SBS.isActive, 0);
            
            %   INTEGER AMBIGUITY RESOLUTION
            % ===============================================================
            
            this.setElVal(this.idUI.cLAMBDA, state.flag_iar, 0);
            this.setElVal(this.idUI.lLAMBDAMethod, state.iar_mode+1, 0);
            this.setElVal(this.idUI.nP0, num2str(state.iar_p0,'%g'), 0);
            this.setElVal(this.idUI.cP0, state.flag_iar_default_p0, 0);
            this.setElVal(this.idUI.nMu, num2str(state.iar_mu,'%g'), 0);
            this.setElVal(this.idUI.cMu, state.flag_iar_auto_mu, 0);
            
            %   INPUT/OUTPUT FILE AND FOLDERS
            % ===============================================================
            
            % The new goGPS version is moving the settings folder from
            % goGPS->settings to data->deprecate_settings, the new settings
            % system is actually replacing the old approach of a .mat file
            % + ini file. the new ini flile system will be stoRED in a
            % project folder
            if not(isempty(state.input_file_ini_path)) && not(exist(state.input_file_ini_path,'file'))
                [path, name, ext] = fileparts(checkPath(state.input_file_ini_path));
                state.setDeprecateIniPath([regexprep(path, './settings', '../data/old/settings/') name ext]);
            end
            this.setElVal(this.idUI.sINI, state.input_file_ini_path, 0);

            this.setElVal(this.idUI.sDirGoOut, state.out_dir, 0);
            this.setElVal(this.idUI.sPrefixGoOut, state.out_prefix, 0);
            
            this.setElVal(this.idUI.cGPS, ss_list.GPS.isActive(), 0);
            this.setElVal(this.idUI.cGLONASS, ss_list.GLO.isActive(), 0);
            this.setElVal(this.idUI.cGalileo, ss_list.GAL.isActive(), 0);
            this.setElVal(this.idUI.cBeiDou, ss_list.BDS.isActive(), 0);
            this.setElVal(this.idUI.cQZSS, ss_list.QZS.isActive(), 0);
            this.setElVal(this.idUI.cSBAS, ss_list.SBS.isActive(), 0);
            
            %   SETTINGS - MASTER STATION
            % ===============================================================
            
            this.setElVal(this.idUI.lCRS, 1, 0);
            
            this.setElVal(this.idUI.nMX, state.mpos.X, 0);
            this.setElVal(this.idUI.nMY, state.mpos.Y, 0);
            this.setElVal(this.idUI.nMZ, state.mpos.Z, 0);
            this.setElVal(this.idUI.nMLat, 0, 0);
            this.setElVal(this.idUI.nMLon, 0, 0);
            this.setElVal(this.idUI.nMh, 0, 0);
            
            %   SETTINGS - KALMAN FILTER - STD
            % ===============================================================
            
            this.setElVal(this.idUI.nStdE, num2str(state.std_k_ENU.E,'%g'), 0);
            this.setElVal(this.idUI.nStdN, num2str(state.std_k_ENU.N,'%g'), 0);
            this.setElVal(this.idUI.nStdU, num2str(state.std_k_ENU.U,'%g'), 0);
            this.setElVal(this.idUI.nStdCode, num2str(state.std_code,'%g'), 0);
            this.setElVal(this.idUI.nStdPhase, num2str(state.std_phase,'%g'), 0);
            this.setElVal(this.idUI.nStdDTM, num2str(state.std_dtm,'%g'), 0);
            this.setElVal(this.idUI.nHAntenna, num2str(state.antenna_h,'%g'), 0);
            this.setElVal(this.idUI.bStdPhase, state.std_phase < 1e30, 0);
            this.setElVal(this.idUI.bStdDTM, state.std_dtm < 1e30, 0);
            this.setElVal(this.idUI.nStdT0, num2str(state.sigma0_k_pos,'%g'), 0);
            this.setElVal(this.idUI.nStdVel, num2str(state.std_k_vel_mod,'%g'), 0);
                                    
            %   SETTINGS - OBSERVATION MODELLING
            % ===============================================================
            this.setElVal(this.idUI.lWeight, state.w_mode + 1, 0);
            this.setElVal(this.idUI.lIono, state.iono_model + 1, 0);
            this.setElVal(this.idUI.lTropo, state.tropo_model + 1, 0);

            %   SETTINGS - KALMAN FILTER
            % ===============================================================
            
            this.setElVal(this.idUI.nCS, num2str(state.cs_thr_pre_pro, '%g'), 0);
            this.setElVal(this.idUI.cStopGoStop, state.stop_go_stop, 0);
            
            %   SETTINGS - KALMAN FILTER - DYNAMIC MODEL
            % ===============================================================
            
            this.resetDynModel();
            if state.isPP(state.p_mode)
                interface2settings = [3 1 2 4];
                this.setElVal(this.idUI.lDynModel, interface2settings(state.kf_order + 1));
            else
                this.setElVal(this.idUI.lDynModel, state.kf_order + 1, 0);
            end

            
            %   SETTINGS - KALMAN FILTER - ARAA
            % ===============================================================
            
            this.setElVal(this.idUI.lARAA, state.iar_restart_mode + 1, 0);
            
            %   SETTINGS - PORTS
            % ===============================================================
            
            this.setElVal(this.idUI.lnPorts, state.c_n_receivers, 0);
            
            rates = this.UI_C_SRATE;
            this.setElVal(this.idUI.lRate, find(ismember(rates, state.c_rate)), 0); %#ok<FNDSB>

            % Match the settings with the com path of the local machine 
            contents = get(this.goh.com_select_0,'String');            

            for r = 1 : min(4,state.c_n_receivers)
                % Find if one com_addr, match the one in the settings
                i = numel(contents);
                while (i > 1) && not(strcmp(contents{i},state.c_com_addr(r)))
                    i = i - 1;
                end
                this.setElVal(this.idUI.(sprintf('lPort%d',r)), i);
                this.setElVal(this.idUI.(sprintf('lProt%d',r)), state.c_prtc);
            end
            
            %   SETTINGS - MASTER SERVER
            % ===============================================================
            
            this.setElVal(this.idUI.sIPaddr, state.ntrip.ip_addr, 0);
            this.setElVal(this.idUI.sIPport, state.ntrip.port, 0);
            this.setElVal(this.idUI.sMnt, state.ntrip.mountpoint, 0);
            
            this.setElVal(this.idUI.sUName, state.ntrip.username, 0);
            this.setPassword(state.ntrip.password);
            
            this.setElVal(this.idUI.nVLat, num2str(state.ntrip.approx_position.lat,'%g'), 0);
            this.setElVal(this.idUI.nVLon, num2str(state.ntrip.approx_position.lon,'%g'), 0);
            this.setElVal(this.idUI.nVH, num2str(state.ntrip.approx_position.h,'%g'), 1);

            % Check all the dependencies
            this.syncFromGUI(this.idUI.lProcMode);
        end
        
        % Load the state of the gui from a matlab file.
        function importLegacyStateMatlab(this,file_name)
            % Load the state of the gui from a matlab file.
            load(file_name); % the file contains the variable state
            this.status = state;
            
            %   MODE
            % ===============================================================
            
            this.setElVal(this.idUI.lProcMode, state.mode, 0);
            
            this.initCaptureMode();
            this.setElVal(this.idUI.lCaptMode, state.nav_mon, 0);
            this.initAlgorithmType();
            this.setElVal(this.idUI.lAlgType, state.kalman_ls, 0);
            this.initProcessingType();
            this.setElVal(this.idUI.lProcType, state.code_dd_sa, 0);
            if (isfield(state,'tropo'))
                this.setElVal(this.idUI.cTropo, state.tropo, 0);
            end
            
            %   DATA SELECTION
            % ===============================================================
            
            if (isfield(state,'activeFreq'))
                this.setElVal(this.idUI.cL1, state.activeFreq(1), 0);
                this.setElVal(this.idUI.cL2, state.activeFreq(2), 0);
                this.setElVal(this.idUI.cL5, state.activeFreq(3), 0);
                this.setElVal(this.idUI.cL6, state.activeFreq(4), 0);
            end
            
            if (isfield(state,'srate'))
                this.setElVal(this.idUI.lProcRate, state.srate, 0);
            end
            if (isfield(state,'obs_comb'))
                this.setElVal(this.idUI.lObsComb, state.obs_comb, 0);
            end
            
            this.setElVal(this.idUI.nCutOff, state.cut_off, 0);
            this.setElVal(this.idUI.nSNR, state.snr_thres, 0);
            this.setElVal(this.idUI.nMinNSat, state.min_sat, 0);
            if (isfield(state,'min_arc'))
                this.setElVal(this.idUI.nMinArc, state.min_arc, 0);
            end

            %   OUTLIER DETECTION
            % ===============================================================
            
            if (isfield(state,'outlier'))
                this.setElVal(this.idUI.cOutlier, state.outlier, 0);                
            end
            if (isfield(state,'spp_thr'))
                this.setElVal(this.idUI.nSPPthr, state.spp_thr, 0);                
            end
            if (isfield(state,'code_thr'))
                this.setElVal(this.idUI.nCodeThr, state.code_thr, 0);                
            end
            if (isfield(state,'phase_thr'))
                this.setElVal(this.idUI.nPhaseThr, state.phase_thr, 0);                
            end            
            
            %   OPTIONS
            % ===============================================================
            
            if (isfield(state,'pre_pro'))
                this.setElVal(this.idUI.cPrePro, state.pre_pro, 0);
            end
            this.setElVal(this.idUI.cMPos, state.master_pos, 0);
            this.setElVal(this.idUI.cConstraint, state.constraint, 0);
            this.setElVal(this.idUI.cPlotProc, state.plotproc, 0);
            this.setElVal(this.idUI.cRefPath, state.ref_path, 0);
            this.setElVal(this.idUI.cSkyPlot, state.no_skyplot_snr, 0);
            this.setElVal(this.idUI.cGEarth, state.google_earth, 0);
            this.setElVal(this.idUI.cErrEllipse, state.err_ellipse, 0);
            this.setElVal(this.idUI.cPlotMaster, state.plot_master, 0);
            this.setElVal(this.idUI.cPlotAmb, state.plot_amb, 0);
            this.setElVal(this.idUI.cUseNTRIP, state.use_ntrip, 0);
            this.setElVal(this.idUI.cDoppler, state.flag_doppler, 0);
            if (isfield(state,'ocean'))
                this.setElVal(this.idUI.cOcean, state.ocean, 0);
            end
            % Temporary check in the migration to SBAS use period
            if (isfield(state,'use_sbas')) %since v0.3.2beta -> backward compatibility
                this.setElVal(this.idUI.cUse_SBAS, state.use_sbas, 0);
            else
                this.setElVal(this.idUI.cUse_SBAS, 0, 0);
            end
            
            %   INTEGER AMBIGUITY RESOLUTION
            % ===============================================================
            
            this.setElVal(this.idUI.cLAMBDA, state.use_lambda, 0);
            this.setElVal(this.idUI.lLAMBDAMethod, state.lambda_method, 0);
            this.setElVal(this.idUI.nP0, state.lambda_P0, 0);
            this.setElVal(this.idUI.cP0, state.lambda_default_P0, 0);
            this.setElVal(this.idUI.nMu, state.lambda_mu, 0);
            this.setElVal(this.idUI.cMu, state.lambda_auto_mu, 0);
            
            %   INPUT/OUTPUT FILE AND FOLDERS
            % ===============================================================
            
            if (isfield(state,'INIsettings')) % backward compatibility check
                if not(exist(state.INIsettings,'file'))
                    [path name ext] = fileparts(checkPath(state.INIsettings));
                    state.INIsettings = [regexprep(path, './settings', '../data/old/settings/') name ext];                    
                end
                this.setElVal(this.idUI.sINI, state.INIsettings, 0);
            end
            this.setElVal(this.idUI.sDirGoOut, state.gogps_data_output, 0);
            this.setElVal(this.idUI.sPrefixGoOut, state.gogps_data_output_prefix, 0);
            if (isfield(state,'activeGNSS'))
                this.setElVal(this.idUI.cGPS, state.activeGNSS(1), 0);
                this.setElVal(this.idUI.cGLONASS, state.activeGNSS(2), 0);
                this.setElVal(this.idUI.cGalileo, state.activeGNSS(3), 0);
                this.setElVal(this.idUI.cBeiDou, state.activeGNSS(4), 0);
                this.setElVal(this.idUI.cQZSS, state.activeGNSS(5), 0);
                this.setElVal(this.idUI.cSBAS, state.activeGNSS(6), 0);
            end
            
            %   SETTINGS - MASTER STATION
            % ===============================================================
            
            this.setElVal(this.idUI.lCRS, state.crs, 0);
            
            this.setElVal(this.idUI.nMX, state.master_X, 0);
            this.setElVal(this.idUI.nMY, state.master_Y, 0);
            this.setElVal(this.idUI.nMZ, state.master_Z, 0);
            this.setElVal(this.idUI.nMLat, state.master_lat, 0);
            this.setElVal(this.idUI.nMLon, state.master_lon, 0);
            this.setElVal(this.idUI.nMh, state.master_h, 0);
            
            %   SETTINGS - KALMAN FILTER - STD
            % ===============================================================
            
            this.setElVal(this.idUI.nStdE, state.std_X, 0);
            this.setElVal(this.idUI.nStdN, state.std_Y, 0);
            this.setElVal(this.idUI.nStdU, state.std_Z, 0);
            this.setElVal(this.idUI.nStdCode, state.std_code, 0);
            this.setElVal(this.idUI.nStdPhase, state.std_phase, 0);
            this.setElVal(this.idUI.nStdDTM, state.std_dtm, 0);
            this.setElVal(this.idUI.nHAntenna, state.antenna_h, 0);
            this.setElVal(this.idUI.bStdPhase, state.toggle_std_phase, 0);
            this.setElVal(this.idUI.bStdDTM, state.toggle_std_dtm, 0);
            this.setElVal(this.idUI.nStdT0, state.std_init, 0);
            this.setElVal(this.idUI.nStdVel, state.std_vel, 0);
                                    
            %   SETTINGS - OBSERVATION MODELLING
            % ===============================================================
            if (isfield(state,'wModel'))
                this.setElVal(this.idUI.lWeight, state.wModel, 0);
            end
            if (isfield(state,'ionoModel'))
                this.setElVal(this.idUI.lIono, state.ionoModel, 0);
            end
            if (isfield(state,'tropoModel'))
                this.setElVal(this.idUI.lTropo, state.tropoModel, 0);
            end

            %   SETTINGS - KALMAN FILTER
            % ===============================================================
            
            this.setElVal(this.idUI.nCS, state.cs_thresh, 0);
            this.setElVal(this.idUI.cStopGoStop, state.stopGOstop, 0);
            
            %   SETTINGS - KALMAN FILTER - DYNAMIC MODEL
            % ===============================================================
            
            this.resetDynModel();
            this.setElVal(this.idUI.lDynModel, state.dyn_mod, 0);
            
            %   SETTINGS - KALMAN FILTER - ARAA
            % ===============================================================
            
            this.setElVal(this.idUI.lARAA, state.amb_select, 0);
            
            %   SETTINGS - PORTS
            % ===============================================================
            
            if (isfield(state,'captureRate'))
                this.setElVal(this.idUI.lRate, state.captureRate, 0);
            end
            [s0 s1 s2 s3] = this.getPortValues(state.com_select_0, state.com_select_1, state.com_select_2, state.com_select_3);
            
            this.setElVal(this.idUI.lnPorts, state.num_receivers, 0);
            
            this.setElVal(this.idUI.lPort0, s0, 0);
            this.setElVal(this.idUI.lPort1, s1, 0);
            this.setElVal(this.idUI.lPort2, s2, 0);
            this.setElVal(this.idUI.lPort3, s3, 0);
            this.setElVal(this.idUI.lProt0, state.protocol_select_0, 0);
            this.setElVal(this.idUI.lProt1, state.protocol_select_1, 0);
            this.setElVal(this.idUI.lProt2, state.protocol_select_2, 0);
            this.setElVal(this.idUI.lProt3, state.protocol_select_3, 0);
            
            %   SETTINGS - MASTER SERVER
            % ===============================================================
            
            this.setElVal(this.idUI.sIPaddr, state.IP_address, 0);
            this.setElVal(this.idUI.sIPport, state.port, 0);
            this.setElVal(this.idUI.sMnt, state.mountpoint, 0);
            
            this.setElVal(this.idUI.sUName, state.username, 0);
            this.setPassword(state.password);
            
            this.setElVal(this.idUI.nVLat, state.approx_lat, 0);
            this.setElVal(this.idUI.nVLon, state.approx_lon, 0);
            this.setElVal(this.idUI.nVH, state.approx_h, 1);

            % Check all the dependencies
            this.syncFromGUI(this.idUI.lProcMode);
        end
        
        % Save the status of the gui to a matlab file
        function exportStateMatlab(this,file_name)
            % Save the status of the gui to a matlab file
            
            %   MODE
            % ===============================================================
            
            tmp_state.mode              = this.getElVal(this.idUI.lProcMode);
            tmp_state.nav_mon           = this.getElVal(this.idUI.lCaptMode);
            tmp_state.kalman_ls         = this.getElVal(this.idUI.lAlgType);
            tmp_state.code_dd_sa        = this.getElVal(this.idUI.lProcType);
            tmp_state.tropo             = this.getElVal(this.idUI.cTropo);

            %   DATA SELECTION
            % ===============================================================
            
            tmp_state.activeFreq        = [this.getElVal(this.idUI.cL1) ...
                                       this.getElVal(this.idUI.cL2) ...
                                       this.getElVal(this.idUI.cL5) ...
                                       this.getElVal(this.idUI.cL6)];
            tmp_state.srate             = this.getElVal(this.idUI.lProcRate);
            tmp_state.obs_comb          = this.getElVal(this.idUI.lObsComb);
            tmp_state.ocean             = this.getElVal(this.idUI.cOcean);

            tmp_state.cut_off           = this.getElVal(this.idUI.nCutOff);
            tmp_state.snr_thres         = this.getElVal(this.idUI.nSNR);
            tmp_state.min_sat           = this.getElVal(this.idUI.nMinNSat);
            tmp_state.min_arc           = this.getElVal(this.idUI.nMinArc);

            %   OPTIONS
            % ===============================================================

            tmp_state.pre_pro           = this.getElVal(this.idUI.cPrePro);
            tmp_state.master_pos        = this.getElVal(this.idUI.cMPos);
            tmp_state.constraint        = this.getElVal(this.idUI.cConstraint);
            tmp_state.plotproc          = this.getElVal(this.idUI.cPlotProc);
            tmp_state.ref_path          = this.getElVal(this.idUI.cRefPath);
            tmp_state.no_skyplot_snr    = this.getElVal(this.idUI.cSkyPlot);
            tmp_state.google_earth      = this.getElVal(this.idUI.cGEarth);
            tmp_state.err_ellipse       = this.getElVal(this.idUI.cErrEllipse);
            tmp_state.plot_master       = this.getElVal(this.idUI.cPlotMaster);
            tmp_state.plot_amb          = this.getElVal(this.idUI.cPlotAmb);
            tmp_state.use_ntrip         = this.getElVal(this.idUI.cUseNTRIP);
            tmp_state.flag_doppler      = this.getElVal(this.idUI.cDoppler);
            tmp_state.use_sbas          = this.getElVal(this.idUI.cUse_SBAS);
            tmp_state.outlier           = this.getElVal(this.idUI.cOutlier);
            tmp_state.spp_thr           = this.getElVal(this.idUI.nSPPthr);
            tmp_state.code_thr          = this.getElVal(this.idUI.nCodeThr);
            tmp_state.phase_thr         = this.getElVal(this.idUI.nPhaseThr);
            tmp_state.use_sbas          = this.getElVal(this.idUI.cUse_SBAS);
            
            %   INTEGER AMBIGUITY RESOLUTION
            % ===============================================================
            
            tmp_state.use_lambda        = this.getElVal(this.idUI.cLAMBDA);
            tmp_state.lambda_method     = this.getElVal(this.idUI.lLAMBDAMethod);
            tmp_state.lambda_P0         = this.getElVal(this.idUI.nP0);
            tmp_state.lambda_default_P0 = this.getElVal(this.idUI.cP0);
            tmp_state.lambda_mu         = this.getElVal(this.idUI.nMu);
            tmp_state.lambda_auto_mu    = this.getElVal(this.idUI.cMu);

            %   INPUT/OUTPUT FILE AND FOLDERS
            % ===============================================================

            tmp_state.INIsettings       = this.getElVal(this.idUI.sINI);
            tmp_state.gogps_data_output = this.getElVal(this.idUI.sDirGoOut);
            tmp_state.gogps_data_output_prefix = this.getElVal(this.idUI.sPrefixGoOut);
            tmp_state.activeGNSS        = [this.isActive(this.idUI.cGPS) ...
                                       this.isActive(this.idUI.cGLONASS) ...
                                       this.isActive(this.idUI.cGalileo) ...
                                       this.isActive(this.idUI.cBeiDou) ...
                                       this.isActive(this.idUI.cQZSS) ...
                                       this.isActive(this.idUI.cSBAS) ];

            %   SETTINGS - MASTER STATION
            % ===============================================================

            tmp_state.crs               = this.getElVal(this.idUI.lCRS);
            tmp_state.master_X          = this.getElVal(this.idUI.nMX); 
            if (isnan(tmp_state.master_X)); tmp_state.master_X = 0; end
            tmp_state.master_Y          = this.getElVal(this.idUI.nMY); 
            if (isnan(tmp_state.master_Y)); tmp_state.master_Y = 0; end
            tmp_state.master_Z          = this.getElVal(this.idUI.nMZ); 
            if (isnan(tmp_state.master_Z)); tmp_state.master_Z = 0; end
            tmp_state.master_lat        = this.getElVal(this.idUI.nMLat);
            if (isnan(tmp_state.master_lat)); tmp_state.master_lat = 0; end
            tmp_state.master_lon        = this.getElVal(this.idUI.nMLon);
            if (isnan(tmp_state.master_lon)); tmp_state.master_lon = 0; end
            tmp_state.master_h          = this.getElVal(this.idUI.nMh);
            if (isnan(tmp_state.master_h)); tmp_state.master_h = 0; end
            
            %   SETTINGS - KALMAN FILTER - STD
            % ===============================================================
                        
            tmp_state.std_X             = this.getElVal(this.idUI.nStdE);
            tmp_state.std_Y             = this.getElVal(this.idUI.nStdN);
            tmp_state.std_Z             = this.getElVal(this.idUI.nStdU);
            tmp_state.std_code          = this.getElVal(this.idUI.nStdCode);
            tmp_state.std_phase         = this.getElVal(this.idUI.nStdPhase);
            tmp_state.std_dtm           = this.getElVal(this.idUI.nStdDTM);
            tmp_state.toggle_std_phase  = this.getElVal(this.idUI.bStdPhase);
            tmp_state.toggle_std_dtm    = this.getElVal(this.idUI.bStdDTM);
            tmp_state.std_init          = this.getElVal(this.idUI.nStdT0);
            tmp_state.std_vel           = this.getElVal(this.idUI.nStdVel);
            tmp_state.antenna_h         = this.getElVal(this.idUI.nHAntenna);
            
            %   SETTINGS - OBSERVATION MODELLING
            % ===============================================================
            tmp_state.wModel            = this.getElVal(this.idUI.lWeight);
            tmp_state.ionoModel         = this.getElVal(this.idUI.lIono);
            tmp_state.tropoModel        = this.getElVal(this.idUI.lTropo);            

            %   SETTINGS - KALMAN FILTER
            % ===============================================================

            tmp_state.cs_thresh         = this.getElVal(this.idUI.nCS);
            tmp_state.stopGOstop        = this.getElVal(this.idUI.cStopGoStop);
            
            %   SETTINGS - KALMAN FILTER - DYNAMIC MODEL
            % ===============================================================
                        
            tmp_state.dyn_mod           = this.getElVal(this.idUI.lDynModel);
            
            %   SETTINGS - KALMAN FILTER - ARAA
            % ===============================================================
            
            tmp_state.amb_select        = this.getElVal(this.idUI.lARAA);
                
            %   SETTINGS - PORTS
            % ===============================================================
            
            tmp_state.captureRate       = get(this.goh.pumCaptureRate,'Value');
            tmp_state.num_receivers     = this.getElVal(this.idUI.lnPorts);
            contents = cellstr(get(this.goh.com_select_0,'String'));
            tmp_state.com_select_0 = contents{get(this.goh.com_select_0,'Value')};
            contents = cellstr(get(this.goh.com_select_1,'String'));
            tmp_state.com_select_1 = contents{get(this.goh.com_select_1,'Value')};
            contents = cellstr(get(this.goh.com_select_2,'String'));
            tmp_state.com_select_2 = contents{get(this.goh.com_select_2,'Value')};
            contents = cellstr(get(this.goh.com_select_3,'String'));
            tmp_state.com_select_3 = contents{get(this.goh.com_select_3,'Value')};                       
            tmp_state.protocol_select_0 = this.getElVal(this.idUI.lProt0);
            tmp_state.protocol_select_1 = this.getElVal(this.idUI.lProt1);
            tmp_state.protocol_select_2 = this.getElVal(this.idUI.lProt2);
            tmp_state.protocol_select_3 = this.getElVal(this.idUI.lProt3);
            
            %   SETTINGS - MASTER SERVER
            % ===============================================================
            
            tmp_state.IP_address        = this.getElVal(this.idUI.sIPaddr);
            tmp_state.port              = this.getElVal(this.idUI.sIPport);
            tmp_state.mountpoint        = this.getElVal(this.idUI.sMnt);
            tmp_state.username          = this.getElVal(this.idUI.sUName);
            tmp_state.password          = this.getPassword();
            tmp_state.approx_lat        = this.getElVal(this.idUI.nVLat);
            tmp_state.approx_lon        = this.getElVal(this.idUI.nVLon);
            tmp_state.approx_h          = this.getElVal(this.idUI.nVH);
            
            this.state.legacyImport(tmp_state);
            this.state.save(file_name);
        end
    end
      
    %   GO FUNCTIONS (OUTPUT)
    % -------------------------------------------------------------------------
    % This part still needs to be modified (cleaned)
    methods
        % Function to return values to goGPS.m
        function go(this)
            % Function to return values to goGPS.m
            global goObj goIni
            this.saveConstellations();

            %master station coordinates
            crs_contents = cellstr(get(this.goh.crs,'String'));
            master_X = str2double(get(this.goh.master_X,'String'));
            master_Y = str2double(get(this.goh.master_Y,'String'));
            master_Z = str2double(get(this.goh.master_Z,'String'));
            master_lat = str2double(get(this.goh.master_lat,'String'));
            master_lon = str2double(get(this.goh.master_lon,'String'));
            master_h = str2double(get(this.goh.master_h,'String'));
            %KF parameters
            std_init = str2double(get(this.goh.std_init,'String'));
            std_X = str2double(get(this.goh.std_X,'String'));
            std_Y = str2double(get(this.goh.std_Y,'String'));
            std_Z = str2double(get(this.goh.std_Z,'String'));
            std_vel = str2double(get(this.goh.std_vel,'String'));
            std_code = str2double(get(this.goh.std_code,'String'));
            if (get(this.goh.toggle_std_phase,'Value'))
                std_phase = str2double(get(this.goh.std_phase,'String'));
            else
                std_phase = 1e30;
            end
            if (get(this.goh.toggle_std_dtm,'Value'))
                std_dtm = str2double(get(this.goh.std_dtm,'String'));
            else
                std_dtm = 1e30;
            end
            min_nsat = str2double(get(this.goh.min_sat,'String'));
            cutoff = str2double(get(this.goh.cut_off,'String'));
            snr_threshold = str2double(get(this.goh.snr_thres,'String'));
            cs_threshold = str2double(get(this.goh.cs_thresh,'String'));
            antenna_h = str2double(get(this.goh.antenna_h,'String'));
            contents_dyn_mod = cellstr(get(this.goh.dyn_mod,'String'));
            flag_stopGOstop = get(this.goh.stopGOstop,'Value');
            %input files
            filerootOUT = [get(this.goh.sDirGoOut,'String') '/' get(this.goh.sPrefixGoOut,'String')];
            if this.isPostProc()
                data_path = goIni.getData('Bin','data_path');
                file_prefix = goIni.getData('Bin','file_prefix');
                filerootIN = [data_path file_prefix];
                data_path = goIni.getData('Receivers','data_path');
                file_name = goIni.getData('Receivers','file_name');
                file_name_R_obs = [data_path file_name];
                data_path = goIni.getData('Master','data_path');
                file_name = goIni.getData('Master','file_name');
                file_name_M_obs = [data_path file_name];
                data_path = goIni.getData('Navigational','data_path');
                file_name = goIni.getData('Navigational','file_name');
                file_name_nav = [data_path file_name];
                ref_path = get(this.goh.ref_path, 'Value');
                data_path = goIni.getData('RefPath','data_path');
                file_name = goIni.getData('RefPath','file_name');
                file_name_ref = [data_path file_name];
                data_path = goIni.getData('DTM','data_path');
                dtm_dir = data_path;
                data_path = goIni.getData('PCO_PCV_file','data_path');
                file_name = goIni.getData('PCO_PCV_file','file_name');
                file_name_pco = [data_path file_name];
                data_path = goIni.getData('OCEAN_LOADING_file','data_path');
                file_name = goIni.getData('OCEAN_LOADING_file','file_name');
                file_name_blq = [data_path file_name];
                data_path = goIni.getData('STATIONS_file','data_path');
                file_name = goIni.getData('STATIONS_file','file_name');
                file_name_sta = [data_path file_name];
            end
            
            %serial communication
            % global COMportR
            contents = cellstr(get(this.goh.com_select_0,'String'));
            COMportR0 = contents{get(this.goh.com_select_0,'Value')};
            % contents = cellstr(get(this.goh.com_select_1,'String'));
            % COMportR1 = contents{get(this.goh.com_select_1,'Value')};
            % contents = cellstr(get(this.goh.com_select_2,'String'));
            % COMportR2 = contents{get(this.goh.com_select_2,'Value')};
            % contents = cellstr(get(this.goh.com_select_3,'String'));
            % COMportR3 = contents{get(this.goh.com_select_3,'Value')};
            %TCPIP / NTRIP
            flag_NTRIP = get(this.goh.use_ntrip,'Value');
            master_ip = get(this.goh.IP_address,'String');
            master_port = str2double(get(this.goh.port,'String'));
            ntrip_mountpoint = get(this.goh.mountpoint,'String');
            %functioning mode
            mode = this.getgoGPSMode();
            
            % If I'm in a mode that uses objects instead of regular code, set goObj flag to 1
            if (mode == goGNSS.MODE_PP_KF_CP_DD_MR)
                goObj = true;
                % init the objects:
            else
                goObj = false;	% set to 1 when goGPS objects are used instead of the regular code
            end
            
            ready = 1;
                        
            if this.isPostProc()
                %check if the dataset was surveyed with a variable dynamic model
                d = dir([filerootIN '_dyn_000.bin']);
                if (this.isPostProc && (flag_stopGOstop || strcmp(contents_dyn_mod{get(this.goh.dyn_mod,'Value')},'Variable')) && isempty(d))
                    msgbox('The selected dataset was not surveyed with a variable dynamic model: please select another dynamic model.'); ready = 0;
                end
            end
            
            if (mode == goGNSS.MODE_RT_R_MON || mode == goGNSS.MODE_RT_RM_MON || mode == goGNSS.MODE_RT_NAV) %if a COM connection to the rover is requiRED
                if(strcmp(COMportR0, 'NA'))
                    msgbox('Please select an existing COM port.'); ready = 0;
                end
            end
            
            if (mode == goGNSS.MODE_RT_M_MON || mode == goGNSS.MODE_RT_RM_MON || mode == goGNSS.MODE_RT_NAV) %if a TCP/IP connection to the master is requiRED
                if (isempty(master_ip))
                    msgbox('Please provide an IP address for the connection to the master.'); ready = 0;
                elseif (isnan(master_port) || master_port < 0 || master_port > 65535)
                    msgbox('Please provide a valid port number for the connection to the master (between 0 and 65535).'); ready = 0;
                end
                if (flag_NTRIP) %if a NTRIP connection is requiRED
                    if (isempty(ntrip_mountpoint))
                        msgbox('Please provide a mountpoint for the NTRIP connection.'); ready = 0;
                    end
                end
            end
            
            if (this.isEnabled(this.idUI.cLAMBDA) && this.isActive(this.idUI.cLAMBDA) && ~this.isLambda2) %if LAMBDA3.x is requested
                if (~exist('LAMBDA.m','file') || ~exist('ratiotab.mat','file'))
                    msgbox(['LAMBDA 3.x code not found. Please download it from http://gnss.curtin.edu.au/research/lambda.cfm and place it in the working path (e.g. in ./positioning/lambda/lambda_v3). Switching ambiguity resolution method to' this.strLAMBDAMethod{this.idILS_enum_old} '...']); ready = 0;
                    this.setElVal(this.idUI.lLAMBDAMethod,1);
                end
            end
            
            if (ready)
                % If the working folder does not exist
                if isempty(dir(this.getSettingsDir()))
                    msgbox('Non existent settings folder. It has beeen probably erased! It is not possible to save the last state.');
                else
                    this.exportStateMatlab(Main_Settings.LAST_SETTINGS);
                end
                uiresume(this.goh.main_panel);
            end
        end
        
        % Function to return values to goGPS.m
        function funout = outputFun(this)
            % Function to return values to goGPS.m
            global goIni;
            if isempty(goIni)
                goIni = Go_Ini_Manager;
            end
            
            this.saveConstellations();
            mode = this.getgoGPSMode();
            mode_vinc = get(this.goh.constraint,'Value') * this.isActive(this.idUI.cConstraint);
            contents_dyn_mod = cellstr(get(this.goh.dyn_mod,'String'));
            if (strcmp(contents_dyn_mod{get(this.goh.dyn_mod,'Value')},'Variable') || get(this.goh.stopGOstop,'Value'))
                flag_var_dyn_model = 1;
            else
                flag_var_dyn_model = 0;
            end

            % atm model
            iono_model = this.getElVal(this.idUI.lIono) - 1;
            tropo_model = this.getElVal(this.idUI.lTropo) - 1;            
            
            % mixed
            fsep = goIni.getData('Various','field_separator');
            if (isempty(fsep))
                fsep_char = 'default';
            else
                fsep_char = fsep;
            end           
            
            flag_full_prepro = this.getElVal(this.idUI.cPrePro);
            
            mode_ref = get(this.goh.ref_path,'Value');
            flag_ms_pos = get(this.goh.master_pos,'Value');
            flag_ms = get(this.goh.plot_master,'Value');
            flag_ge = get(this.goh.google_earth,'Value');
            flag_cov = get(this.goh.err_ellipse,'Value');
            flag_NTRIP = get(this.goh.use_ntrip,'Value');
            flag_amb = get(this.goh.plot_amb,'Value');
            flag_skyplot = get(this.goh.no_skyplot_snr,'Value');
            flag_plotproc = get(this.goh.plotproc,'Value');
            flag_stopGOstop = get(this.goh.stopGOstop,'Value');
            flag_SBAS = get(this.goh.use_SBAS,'Value');
            flag_IAR = get(this.goh.cLAMBDA,'Value');
            flag_tropo = this.isActive(this.idUI.cTropo);
            flag_ocean = this.isActive(this.idUI.cOcean);
            flag_SEID = this.isSEID();
            active_freq = this.getFreq();
            obs_comb = this.getObsComb();
            flag_outlier =  this.isActive(this.idUI.cOutlier);
            
            processing_rate = this.valProcRate(this.getElVal(this.idUI.lProcRate));
            
            filerootOUT = checkPath([get(this.goh.sDirGoOut,'String') filesep get(this.goh.sPrefixGoOut,'String')]);
            if (this.isPostProc) % I need these informations only in Post Processing
                data_path = goIni.getData('Bin','data_path');
                file_prefix = goIni.getData('Bin','file_prefix');
                filerootIN = checkPath([data_path file_prefix]);
                i = 1;
                j = length(filerootOUT);
                while (~isempty(dir([filerootOUT '_????_rover.bin'])) || ...
                        ~isempty(dir([filerootOUT '_master*.bin'])) || ...
                        ~isempty(dir([filerootOUT '_????_obs*.bin'])) || ...
                        ~isempty(dir([filerootOUT '_????_eph*.bin'])) || ...
                        ~isempty(dir([filerootOUT '_????_dyn*.bin'])) || ...
                        ~isempty(dir([filerootOUT '_sat*.bin'])) || ...
                        ~isempty(dir([filerootOUT '_kal*.bin'])) || ...
                        ~isempty(dir([filerootOUT '_dt*.bin'])) || ...
                        ~isempty(dir([filerootOUT '_conf*.bin'])) || ...
                        ~isempty(dir([filerootOUT '_dop*.bin'])) || ...
                        ~isempty(dir([filerootOUT '_ECEF*.txt'])) || ...
                        ~isempty(dir([filerootOUT '_geod*.txt'])) || ...
                        ~isempty(dir([filerootOUT '_plan*.txt'])) || ...
                        ~isempty(dir([filerootOUT '_????_NMEA*.txt'])) || ...
                        ~isempty(dir([filerootOUT '.kml'])) )
                    
                    filerootOUT(j+1:j+4) = ['_' num2str(i,'%03d')];
                    i = i + 1;
                end
                data_path = goIni.getData('Receivers','data_path');
                file_name = goIni.getData('Receivers','file_name');
                file_name_R_obs = checkPath([data_path file_name]);
                data_path = goIni.getData('Master','data_path');
                file_name = goIni.getData('Master','file_name');
                file_name_M_obs = checkPath([data_path file_name]);
                data_path = goIni.getData('Navigational','data_path');
                file_name = goIni.getData('Navigational','file_name');
                file_name_nav = checkPath([data_path file_name]);
                data_path = goIni.getData('RefPath','data_path');
                file_name = goIni.getData('RefPath','file_name');
                file_name_ref = checkPath([data_path file_name]);
                data_path = goIni.getData('PCO_PCV_file','data_path');
                file_name = goIni.getData('PCO_PCV_file','file_name');
                file_name_pco = checkPath([data_path file_name]);
                data_path = goIni.getData('OCEAN_LOADING_file','data_path');
                file_name = goIni.getData('OCEAN_LOADING_file','file_name');
                file_name_blq = checkPath([data_path file_name]);
                data_path = goIni.getData('STATIONS_file','data_path');
                file_name = goIni.getData('STATIONS_file','file_name');
                file_name_sta = checkPath([data_path file_name]);
                if(this.isMultiReceiver)
                    [multi_antenna_rf, ~] = goIni.getGeometry();
                else
                    multi_antenna_rf = [];
                end
            else
                filerootIN = '';
                file_name_R_obs = '';
                file_name_M_obs = '';
                file_name_nav = '';
                file_name_ref = '';
                file_name_pco = '';
                file_name_blq = '';
                file_name_sta = '';
                rates = get(this.goh.pumCaptureRate,'String');                
                goIni.setCaptureRate(rates{get(this.goh.pumCaptureRate,'Value')});
                multi_antenna_rf = [];
            end
            
            contents = cellstr(get(this.goh.crs,'String'));
            if (strcmp(contents{get(this.goh.crs,'Value')},'ECEF (X,Y,Z)'))
                XM = str2double(get(this.goh.master_X,'String'));
                YM = str2double(get(this.goh.master_Y,'String'));
                ZM = str2double(get(this.goh.master_Z,'String'));
            else
                latM = str2double(get(this.goh.master_lat,'String'));
                lonM = str2double(get(this.goh.master_lon,'String'));
                hM = str2double(get(this.goh.master_h,'String'));
                [XM, YM, ZM] = geod2cart (latM*pi/180, lonM*pi/180, hM, 6378137, 1/298.257222101);
            end
            pos_M_man = [XM; YM; ZM];
            
            contents = cellstr(get(this.goh.num_receivers,'String'));
            num_rec = str2double(contents{get(this.goh.num_receivers,'Value')});
            protocol_idx = nan(4,1);
            
            if num_rec >= 1
                contentsProt = cellstr(get(this.goh.protocol_select_0,'String'));
                if (strcmp(contentsProt{get(this.goh.protocol_select_0,'Value')},'UBX (u-blox)'))
                    protocol_idx(1) = 0;
                elseif (strcmp(contentsProt{get(this.goh.protocol_select_0,'Value')},'iTalk (Fastrax)'))
                    protocol_idx(1) = 1;
                elseif (strcmp(contentsProt{get(this.goh.protocol_select_0,'Value')},'SkyTraq'))
                    protocol_idx(1) = 2;
                elseif (strcmp(contentsProt{get(this.goh.protocol_select_0,'Value')},'BINR (NVS)'))
                    protocol_idx(1) = 3;
                end
                
                if num_rec >= 2
                    contentsProt = cellstr(get(this.goh.protocol_select_1,'String'));
                    if (strcmp(contentsProt{get(this.goh.protocol_select_1,'Value')},'UBX (u-blox)'))
                        protocol_idx(2) = 0;
                    elseif (strcmp(contentsProt{get(this.goh.protocol_select_1,'Value')},'iTalk (Fastrax)'))
                        protocol_idx(2) = 1;
                    elseif (strcmp(contentsProt{get(this.goh.protocol_select_1,'Value')},'SkyTraq'))
                        protocol_idx(2) = 2;
                    elseif (strcmp(contentsProt{get(this.goh.protocol_select_1,'Value')},'BINR (NVS)'))
                        protocol_idx(2) = 3;
                    end
                    
                    if num_rec >= 3
                        contentsProt = cellstr(get(this.goh.protocol_select_2,'String'));
                        if (strcmp(contentsProt{get(this.goh.protocol_select_2,'Value')},'UBX (u-blox)'))
                            protocol_idx(3) = 0;
                        elseif (strcmp(contentsProt{get(this.goh.protocol_select_2,'Value')},'iTalk (Fastrax)'))
                            protocol_idx(3) = 1;
                        elseif (strcmp(contentsProt{get(this.goh.protocol_select_2,'Value')},'SkyTraq'))
                            protocol_idx(3) = 2;
                        elseif (strcmp(contentsProt{get(this.goh.protocol_select_2,'Value')},'BINR (NVS)'))
                            protocol_idx(3) = 3;
                        end
                        
                        if num_rec >= 4
                            contentsProt = cellstr(get(this.goh.protocol_select_3,'String'));
                            if (strcmp(contentsProt{get(this.goh.protocol_select_3,'Value')},'UBX (u-blox)'))
                                protocol_idx(4) = 0;
                            elseif (strcmp(contentsProt{get(this.goh.protocol_select_3,'Value')},'iTalk (Fastrax)'))
                                protocol_idx(4) = 1;
                            elseif (strcmp(contentsProt{get(this.goh.protocol_select_3,'Value')},'SkyTraq'))
                                protocol_idx(4) = 2;
                            elseif (strcmp(contentsProt{get(this.goh.protocol_select_3,'Value')},'BINR (NVS)'))
                                protocol_idx(4) = 3;
                            end
                        end
                    end
                end
            end
            protocol_idx = protocol_idx(~isnan(protocol_idx));
            
            funout = cell(39,1);
            
            funout{1} = mode;
            funout{2} = mode_vinc;
            funout{3} = 0;  % it was mode_data, now goGPS bin files are unsupported, dropping support
            funout{4} = mode_ref;
            funout{5} = flag_ms_pos;
            funout{6} = flag_ms;
            funout{7} = flag_ge;
            funout{8} = flag_cov;
            funout{9} = flag_NTRIP;
            funout{10} = flag_amb;
            funout{11} = flag_skyplot;
            funout{12} = flag_plotproc;
            funout{13} = flag_var_dyn_model;
            funout{14} = flag_stopGOstop;
            funout{15} = flag_SBAS;
            funout{16} = flag_IAR;
            funout{17} = filerootIN;
            funout{18} = filerootOUT;
            funout{19} = file_name_R_obs;
            funout{20} = file_name_M_obs;
            funout{21} = file_name_nav;
            funout{22} = file_name_ref;
            funout{23} = file_name_pco;
            funout{24} = file_name_blq;
            funout{25} = pos_M_man;
            funout{26} = protocol_idx;
            funout{27} = multi_antenna_rf;
            funout{28} = iono_model;
            funout{29} = tropo_model;            
            funout{30} = fsep_char;
            funout{31} = flag_ocean;
            funout{32} = flag_outlier;
            funout{33} = flag_tropo;
            funout{34} = active_freq;
            funout{35} = flag_SEID;
            funout{36} = processing_rate;
            funout{37} = obs_comb;
            funout{38} = flag_full_prepro;
            funout{39} = file_name_sta;
            
            global sigmaq0 sigmaq_vE sigmaq_vN sigmaq_vU sigmaq_vel
            global sigmaq_cod1 sigmaq_cod2 sigmaq_codIF sigmaq_ph sigmaq_phIF sigmaq0_N sigmaq_dtm sigmaq0_tropo sigmaq_tropo sigmaq0_rclock sigmaq_rclock
            global min_nsat min_arc cutoff snr_threshold cs_threshold_preprocessing cs_threshold weights snr_a snr_0 snr_1 snr_A order o1 o2 o3
            global h_antenna
            global tile_header tile_georef dtm_dir
            global master_ip master_port ntrip_user ntrip_pw ntrip_mountpoint
            global nmea_init
            global flag_doppler_cs
            global COMportR
            global IAR_method P0 mu flag_auto_mu flag_default_P0
            global SPP_threshold max_code_residual max_phase_residual

            IAR_method = get(this.goh.lLAMBDAMethod,'Value') - 1;
            P0 = str2double(get(this.goh.nP0,'String'));
            mu = str2double(get(this.goh.nMu,'String'));
            flag_auto_mu = get(this.goh.cMu,'Value') && ~this.isLambda2;
            flag_default_P0 = get(this.goh.cP0,'Value') && ~this.isLambda2;
            
            SPP_threshold = str2double(get(this.goh.nSPPthr,'String'));
            max_code_residual = str2double(get(this.goh.nCodeThr,'String'));
            max_phase_residual = str2double(get(this.goh.nPhaseThr,'String'));

            contents = cellstr(get(this.goh.com_select_0,'String'));
            COMportR0 = contents{get(this.goh.com_select_0,'Value')};
            contents = cellstr(get(this.goh.com_select_1,'String'));
            COMportR1 = contents{get(this.goh.com_select_1,'Value')};
            contents = cellstr(get(this.goh.com_select_2,'String'));
            COMportR2 = contents{get(this.goh.com_select_2,'Value')};
            contents = cellstr(get(this.goh.com_select_3,'String'));
            COMportR3 = contents{get(this.goh.com_select_3,'Value')};
            
            if num_rec >= 1
                COMportR{1,1} = COMportR0;
                if num_rec >= 2
                    COMportR{2,1} = COMportR1;
                    if num_rec >= 3
                        COMportR{3,1} = COMportR2;
                        if num_rec >= 4
                            COMportR{4,1} = COMportR3;
                        end
                    end
                end
            end
            
            flag_doppler_cs = get(this.goh.flag_doppler,'Value');
            sigmaq0 = str2double(get(this.goh.std_init,'String'))^2;
            sigmaq_vE = str2double(get(this.goh.std_X,'String'))^2;
            sigmaq_vN = str2double(get(this.goh.std_Y,'String'))^2;
            sigmaq_vU = str2double(get(this.goh.std_Z,'String'))^2;
            sigmaq_vel = str2double(get(this.goh.std_vel,'String'))^2;
            sigmaq_cod1 = str2double(get(this.goh.std_code,'String'))^2;
            sigmaq_cod2 = 0.16;
            sigmaq_codIF = 1.2^2;
            if (get(this.goh.toggle_std_phase,'Value'))
                sigmaq_ph = str2double(get(this.goh.std_phase,'String'))^2;
                sigmaq_phIF = 0.009^2;
            else
                sigmaq_ph = 1e30;
                sigmaq_phIF = 1e30;
            end
            sigmaq0_N = 1000;
            if (get(this.goh.toggle_std_dtm,'Value'))
                sigmaq_dtm = str2double(get(this.goh.std_dtm,'String'))^2;
            else
                sigmaq_dtm = 1e30;
            end
            sigmaq0_tropo = 1e-2;
            sigmaq_tropo = 2.0834e-07; %(0.005/sqrt(120))^2
            sigmaq0_rclock = 2e-17;
            sigmaq_rclock = 1e3;
            min_nsat =  str2double(get(this.goh.min_sat,'String'));
            min_arc = str2double(get(this.goh.nMinArc,'String'));
            if (mode == 2)
                disp('Minimum number of satellites is forced to 4 (for undifferenced positioning)');
                min_nsat = 4;
            end
            goIni.addSection('Generic');
            goIni.addKey('Generic','cutoff', str2double(get(this.goh.cut_off,'String')));
            cutoff = str2double(get(this.goh.cut_off,'String'));
            goIni.addKey('Generic','snrThr', str2double(get(this.goh.snr_thres,'String')));
            snr_threshold = str2double(get(this.goh.snr_thres,'String'));
            goIni.addKey('Generic','csThr', str2double(get(this.goh.cs_thresh,'String')));
            if this.isPPP()
                cs_threshold = 1e30; %i.e. disable cycle-slip detection during KF processing
                cs_threshold_preprocessing = str2double(get(this.goh.cs_thresh,'String'));
            else
                cs_threshold = str2double(get(this.goh.cs_thresh,'String'));
                cs_threshold_preprocessing = 1;
            end
            
            weights = this.getElVal(this.idUI.lWeight) - 1;
            snr_a = 30;
            snr_0 = 10;
            snr_1 = 50;
            snr_A = 30;
            global amb_restart_method
            contents = cellstr(get(this.id2handle(this.idUI.lARAA),'String'));
            selection = contents{min(get(this.id2handle(this.idUI.lARAA),'Value'), length(contents))};
            if (strcmp(selection, 'Observed code - phase difference'))
                amb_restart_method = 0;
            elseif (strcmp(selection, 'Kalman-pREDicted code - phase difference'))
                amb_restart_method = 1;
            else
                amb_restart_method = 2;
            end
            contents = cellstr(get(this.id2handle(this.idUI.lDynModel),'String'));
            if (strcmp(contents{min(get(this.id2handle(this.idUI.lDynModel),'Value'), length(contents))},'Static'))
                order = 1;
            else
                if (strcmp(contents{min(get(this.id2handle(this.idUI.lDynModel),'Value'), length(contents))},'Const. acceleration'))
                    order = 3;
                elseif (strcmp(contents{min(get(this.id2handle(this.idUI.lDynModel),'Value'), length(contents))},'Const. velocity'))
                    order = 2;
                else
                    order = 1;
                end
            end
            
            o1 = order;
            o2 = order*2;
            o3 = order*3;
            h_antenna = str2double(get(this.goh.antenna_h,'String'));
%             if (this.isPostProc) % I need these informations only in Post Processing
                dtm_dir = goIni.getData('DTM','data_path');
                try
                    load([dtm_dir '/tiles/tile_header'], 'tile_header');
                    load([dtm_dir '/tiles/tile_georef'], 'tile_georef');
                catch e
                    tile_header.nrows = 0;
                    tile_header.ncols = 0;
                    tile_header.cellsize = 0;
                    tile_header.nodata = 0;
                    tile_georef = zeros(1,1,4);
                end
%             end
            master_ip = get(this.goh.IP_address,'String');
            master_port = str2double(get(this.goh.port,'String'));
            ntrip_user = get(this.goh.username,'String');
            ntrip_pw = this.getPassword();
            ntrip_mountpoint = get(this.goh.mountpoint,'String');
            phiApp = str2double(get(this.goh.approx_lat,'String'));
            lamApp = str2double(get(this.goh.approx_lon,'String'));
            hApp = str2double(get(this.goh.approx_h,'String'));
            [XApp,YApp,ZApp] = geod2cart (phiApp*pi/180, lamApp*pi/180, hApp, 6378137, 1/298.257222101);
            if ~isnan(XApp) && ~isnan(YApp) && ~isnan(ZApp)
                nmea_init = NMEA_GGA_gen([XApp YApp ZApp],10);
            else
                nmea_init = '';
            end
        end
        
        % Function to save in the goIni object the status of activation of the various GNSS
        function saveConstellations(this)
            % Function to save in the goIni object the status of activation of the various GNSS
            global goIni
            if isempty(goIni)
                goIni = Go_Ini_Manager;
            end            
            goIni.addSection('Constellations');
            goIni.addKey('Constellations','GPS',this.isActive(this.idUI.cGPS));
            goIni.addKey('Constellations','GLONASS',this.isActive(this.idUI.cGLONASS));
            goIni.addKey('Constellations','Galileo',this.isActive(this.idUI.cGalileo));
            goIni.addKey('Constellations','BeiDou',this.isActive(this.idUI.cBeiDou));
            goIni.addKey('Constellations','QZSS',this.isActive(this.idUI.cQZSS));
            goIni.addKey('Constellations','SBAS',this.isActive(this.idUI.cSBAS));
        end
    end    
    
    
    %   GO FUNCTIONS (OUTPUT)
    % -------------------------------------------------------------------------
    % This part still needs to be modified (cleaned)
    methods
        % Function to load the Edit INI window
        function openEditINI(this)
            % Function to load the Edit INI window
            if (isfield(this.edtINI,'h'))
                if ishandle(this.edtINI.h.wEditINI)
                    close(this.edtINI.h.wEditINI);
                end
                delete this.edtINI.h
            end
            guiEditINI();
        end
        
        % Function to init the INI editor
        % creates, objects, load default values, etc...
        function initEditINI(this, h)
            % Function to init the INI editor
            global goIni
            
            % Save handler to the INI editor
            this.edtINI.h = h;
            
            % Get the name of the ini file
            
            if isobject(goIni)
                file_name = goIni.getFileName();
            else
                file_name = '';
            end
            if isempty(file_name)
                file_name = [this.state.input_file_ini_path];
                file_name = checkPath(file_name);
                if ~exist(file_name, 'file')
                    file_name = '';
                end
            end
            
            % Get the content of the ini file
            this.setGuiElStr(h.sINI, file_name);
            this.setGuiElStr(h.sINIout, file_name);

            if ~isempty(file_name)
                if exist(file_name, 'file')
                    fid = fopen(file_name,'r');
                    text = fread(fid, '*char');
                    text = text';
                    fclose(fid);
                else
                    text = '# No INI file found';
                end
            else
                text = '# No INI file found';
            end
            
            % Undocumented edit box => better management of a text file
            % Create the widget containing the text
            jCodePaneINI = com.mathworks.widgets.SyntaxTextPane;
            jCodePaneINI.setText(text);
            % Create the ScrollPanel containing the widget
            jScrollPaneINI = com.mathworks.mwswing.MJScrollPane(jCodePaneINI);
            % Substitute the eINI edit box with the Java Scroll Pane
            set(this.edtINI.h.eINI, 'Units', 'pixels');
            [jhPanel, hContainerINI] = javacomponent(jScrollPaneINI,get(this.edtINI.h.eINI,'Position'),h.wEditINI);
            delete(this.edtINI.h.eINI);
            
            % Save the new object
            this.edtINI.jEdit.jINI = jCodePaneINI;
            this.edtINI.jEdit.hINI = hContainerINI;
            
            % Load INI keywords
            this.edtINI.keywordsINI = Go_Ini_Manager([this.getSettingsDir() this.defaultINIKeywordsFile]);
            this.edtINI.keywordsINI.readFile();
            % Sections
            sections = this.edtINI.keywordsINI.getData('INI','sections');
            this.setGuiElStr(h.lSections, sections);
            drawnow;
            % Fields
            this.updateFieldsINI();
            
            % Replacing the field
            jCodePaneFields = com.mathworks.widgets.SyntaxTextPane;
            jCodePaneFields.setText('');
            % Create the ScrollPanel containing the widget
            jScrollPaneFields = com.mathworks.mwswing.MJScrollPane(jCodePaneFields);
            % Substitute the eFields edit box with the Java Scroll Pane
            set(this.edtINI.h.eFields, 'Units', 'pixels');
            [jhPanel, hContainerFields] = javacomponent(jScrollPaneFields,get(this.edtINI.h.eFields,'Position'),h.wEditINI);
            delete(this.edtINI.h.eFields);
            
            % Save the new object
            this.edtINI.jEdit.jFields = jCodePaneFields;
            this.edtINI.jEdit.hFields = hContainerFields;
            drawnow;
            this.updateFieldsINI();
            
            % Replacing the field
            jCodePaneBrowse = com.mathworks.widgets.SyntaxTextPane;
            jCodePaneBrowse.setText('');
            % Create the ScrollPanel containing the widget
            jScrollPaneBrowse = com.mathworks.mwswing.MJScrollPane(jCodePaneBrowse);
            % Substitute the eFields edit box with the Java Scroll Pane
            set(this.edtINI.h.sBrowse, 'Units', 'pixels');
            [jhPanel, hContainerBrowse] = javacomponent(jScrollPaneBrowse,get(this.edtINI.h.sBrowse,'Position'),h.wEditINI);
            delete(this.edtINI.h.sBrowse);
            
            % Save the new object
            this.edtINI.jEdit.jBrowse = jCodePaneBrowse;
            this.edtINI.jEdit.hBrowse = hContainerBrowse;
            drawnow;
        end
        
        % Browse INI file => select a file to be edited
        function browseINIEditInFile(this)
            % Browse INI file => select a file to be edited
            % In multi receiver mode, I read from ini file
            
            config_dir = this.state.prj_home;
            if exist([config_dir filesep 'config'], 'dir')
                config_dir = [config_dir filesep 'config'];
            else
                config_dir = this.getSettingsDir();
            end
            [file_name, pathname] = uigetfile( ...
                {'*.ini;','INI configuration file (*.ini)'; ...
                '*.*',  'All Files (*.*)'}, ...
                'Choose an INI configuration file', config_dir);
            if (file_name ~= 0)
                file_name = checkPath([pathname file_name]);

                this.setGuiElStr(this.edtINI.h.sINI, file_name);
                this.setGuiElStr(this.edtINI.h.sINIout, file_name);
                
                % Get the name of the ini file
                if isempty(file_name)
                    file_name = [this.state.input_file_ini_path];
                    if ~exist(file_name, 'file')
                        file_name = '';
                    end
                end
                
                % Get the content of the ini file
                if ~isempty(file_name)
                    fid = fopen(file_name,'r');
                    text = fread(fid, '*char');
                    text = text';
                    fclose(fid);
                else
                    text = '# No INI file found';
                end
                this.edtINI.jEdit.jINI.setText(text);
                drawnow;                
            end
        end
     
        % Save INI
        function saveINI(this)
            % Save INI
            file_name = checkPath(get(this.edtINI.h.sINIout, 'String'));
            
            try
                fid = fopen(file_name,'w');
                fwrite(fid, char(this.edtINI.jEdit.jINI.getText()));
                fclose(fid);
                
                msgbox('The file has been saved correctly');
                % If the main goGPS interface exist
                if (ishandle(this.goh.main_panel))
                    if (file_name ~= 0)
                        this.setElVal(this.idUI.sINI, fullfile(file_name));
                    end
                    this.forceINIupdate();
                end
            catch e
                msgbox(['Error: ' e.message ' Please provide a valid file_name(path)']);
            end
        end
        
        % Update the fields according to the selected section
        function updateFieldsINI(this)
            % Update the fields according to the selected section
            curSection = get(this.edtINI.h.lSections, 'String');
            valSection = get(this.edtINI.h.lSections, 'Value');
            if length(curSection) > 1
                curSection = curSection{valSection};
                
                numFields = this.edtINI.keywordsINI.getData(curSection, 'num_fields');
                strFields = this.edtINI.keywordsINI.getData(curSection, 'str_fields');
                vectFields = this.edtINI.keywordsINI.getData(curSection, 'vect_fields');
                
                str = sprintf('[%s]\n', curSection);
                if ~isempty(numFields)
                    if iscell(numFields)
                        for i=1:length(numFields)
                            str = sprintf('%s%s = 0\n',str, numFields{i});
                        end
                    else
                        str = sprintf('%s%s = 0\n',str, numFields);
                    end
                end
                if ~isempty(strFields)
                    if iscell(strFields)
                        for i=1:length(strFields)
                            str = sprintf('%s%s = "insert a string"\n',str, strFields{i});
                        end
                    else
                        str = sprintf('%s%s = "insert a string"\n',str, strFields);
                    end
                end
                if ~isempty(vectFields)
                    if iscell(vectFields)
                        for i=1:length(vectFields)
                            str = sprintf('%s%s = [0 0 0]\n',str, vectFields{i});
                        end
                    else
                        str = sprintf('%s%s = [0 0 0]\n',str, vectFields);
                    end
                end
                if isfield(this.edtINI.jEdit,'jFields')
                    this.edtINI.jEdit.jFields.setText(str);
                end
            end
        end
        
        % Browse for RINEX file
        function browse4Rin(this)
            % Browse for RINEX file
            % In multi receiver mode, I read from ini file
            [file_name, pathname] = uigetfile( ...
                    {'*.obs;*.??o;*.??O','RINEX observation files (*.obs,*.??o,*.??O)';
                    '*.obs','Observation files (*.obs)'; ...
                    '*.??o;*.??O','Observation files (*.??o,*.??O)'; ...
                    '*.*',  'All Files (*.*)'}, ...
                    'MultiSelect', 'on', ...
                    'Choose a RINEX observation file',[this.getWorkingDir() 'data_RINEX']);
                
            if ~isempty(file_name)
                this.workingDir = [pathname];
                str = sprintf('data_path = "%s"\n', pathname);
                if iscell(file_name)
                    str = sprintf('nRec = %d\n%sfile_name = [', length(file_name), str);
                    for r=1:length(file_name)
                        str = sprintf('%s "%s"',str, file_name{r});                      
                    end
                    str = sprintf('%s ]',str);
                else
                    str = sprintf('%sfile_name = "%s"', str, file_name);
                end
                this.edtINI.jEdit.jBrowse.setText(str);
                clipboard('copy', str);
            end
        end
        
        % Browse for a navigation file
        function browse4Nav(this)
            % Browse for a navigation file
            [file_name, pathname] = uigetfile( ...
                {'*.nav;*.??n;*.??N','RINEX navigation files (*.nav,*.??n,*.??N)';
                '*.nav','Navigation files (*.nav)'; ...
                '*.??n;*.??N','Navigation files (*.??n,*.??N)'; ...
                '*.*',  'All Files (*.*)'}, ...
                'Choose a RINEX navigation file',[this.getWorkingDir() 'data_RINEX']);
            
            if (file_name ~= 0)
                this.workingDir = [pathname];
                str = sprintf('data_path = "%s"\nfile_name = "%s"', pathname, file_name);
                this.edtINI.jEdit.jBrowse.setText(str);
                clipboard('copy', str);
            end
        end
                
        % Browse output foder
        function browse4Dir(this)
            % Browse output foder
            dname = uigetdir(this.getWorkingDir(),'Choose a directory');
            if (dname ~= 0)
                this.workingDir = [dname '../'];
                str = sprintf('data_path = "%s"', dname);
                this.edtINI.jEdit.jBrowse.setText(str);
                clipboard('copy', str);
            end
        end
        
        % Browse for the path containing reference points for constrained solutions
        function browse4Ref(this)
            % Browse for the path containing reference points for constrained solutions
            [file_name, pathname] = uigetfile('*.mat', 'Choose file containing reference path',this.getWorkingDir());
            
            if (file_name ~= 0)
                this.workingDir = [pathname];
                str = sprintf('data_path = "%s"\nfile_name = "%s"', pathname, file_name);
                this.edtINI.jEdit.jBrowse.setText(str);
                clipboard('copy', str);
            end
            this.updateGUI();
        end
        
        % Browse for a Generic File
        function browse4Gen(this)
            % Browse for a Generic File
            [file_name, pathname] = uigetfile( ...
                {'*.*',  'All Files (*.*)'}, ...
                'Choose a file',this.getWorkingDir());
            
            if (file_name ~= 0)
                str = sprintf('data_path = "%s"\nfile_name = "%s"', pathname, file_name);
                this.edtINI.jEdit.jBrowse.setText(str);
                clipboard('copy', str);
            end
        end        
    end  
    
    %   GUI STATIC MODIFIERS
    % -------------------------------------------------------------------------
    % Functions to set some properties of an GUI object
    methods(Static, Access = 'private')
        
        % Enable/Disable a generic element of the interface
        function onoffGuiEl(hObject, state)
            % Enable/Disable a generic element of the interface
            if nargin < 2
                state = 'on';
            end
            set(hObject, 'Enable', state);
        end

        % Enable/Disable a panel element of the interface
        function onoffGuiPanel(hObject, state)
            % Enable/Disable a panel element of the interface
            if nargin < 2
                state = 'on';
            end
            if strcmp(state,'off')
                set(hObject, 'ForegroundColor', goGUIclass.DISABLE_COL);
            else
                set(hObject, 'ForegroundColor', goGUIclass.ENABLE_COL);
            end
        end        
     
        % Get enabled status of a generic element
        function state = isGuiElOn(hObject)
            % Get enabled status of a generic element
            state = strcmp(get(hObject, 'Enable'),'on');
        end
        
        % Get enabled status of a panel element
        function state = isGuiPanelOn(hObject)
            % Get enabled status of a panel element
            state = isequal(get(hObject, 'ForegroundColor'), goGUIclass.ENABLE_COL);
        end
        
        % Get a value from an element of the interface
        function val = getGuiElVal(hObject)
            % Get a value from an element of the interface
            val = get(hObject, 'Value');
        end
        
        % Get a value from an element of the interface
        function val = getGuiElColor(hObject)
            % Get a value from an element of the interface
            val = get(hObject, 'ForegroundColor');
        end
        
        % Get a string from an element of the interface
        function str = getGuiElStr(hObject)
            % Get a string from an element of the interface
            str = get(hObject, 'String');
        end

        % Get a title from an element of the interface
        function str = getGuiElTitle(hObject)
            % Get a title from an element of the interface
            str = get(hObject, 'Title');
        end

        % Set a value of an element of the interface
        function setGuiElVal(hObject, value)
            % Set a value of an element of the interface
            set(hObject, 'Value', value);
        end

        % Set a value of an element of the interface
        function setGuiElColor(hObject, color)
            % Set a value of an element of the interface
            set(hObject, 'ForegroundColor', color);
        end
        
        % Set a string of an element of the interface
        function setGuiElStr(hObject, str)
            % Set a string of an element of the interface
            set(hObject, 'String', str);
        end
        
        % Get a title from an element of the interface
        function setGuiElTitle(hObject, str)
            % Get a title from an element of the interface
            set(hObject, 'Title', str);
        end
        
        % Close box
        function closeGUI(src,evnt)
            % Close box
            global goGUI % I cannot pass the object directly
            selection = questdlg('Do you want to quit goGPS?',...
                '',...
                'Yes','No','Yes');
            switch selection,
                case 'Yes',
                    if isempty(goGUI)  % Something went wrong in the initialization phase
                        delete(gcf);
                    else
                        if isfield(goGUI.goh, 'main_panel');
                            delete(goGUI.goh.main_panel);
                        else % Something went wrong in the initialization phase
                            delete(gcf);
                        end
                    end
                case 'No'
                    return
            end
        end

    end    
        
end
