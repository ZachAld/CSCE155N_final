%Approved by:
%Critical pressures and temperatures from https://www.engineeringtoolbox.com/gas-critical-temperature-pressure-d_161.html
%Reference: Dr. Bilal A. Siddiqui 2016 from https://www.mathworks.com/matlabcentral/fileexchange/59803-compressibility-factor-calculator-exact
function [] = compressibilityGUI()
    global comp
    comp.Pc = 0;
    comp.Tc = 0;
    comp.z = 0;
    comp.fig = figure('numbertitle','off','name','Compressibility Calculator');
    
    %Text and listbox for the user to choose a gas
    comp.gasText = uicontrol('style','text','units','normalized','position',[.1 .85 .2 .1], 'string','Select Gas:','horizontalalignment','left');
    comp.gasChoice = uicontrol('style','listbox','String',{'Air','Nitrogen','Oxygen','Carbon Dioxide','Other Gas'},'units','normalized','position',[.1 .75 .2 .16],'horizontalalignment','right','callback',{@criticalControl});

    %Text and edit box for user to input gas pressure
    comp.pressText = uicontrol('style','text','units','normalized','position',[.4 .85 .2 .1], 'string','Input Pressure (atm):','horizontalalignment','left');
    comp.pressEnter = uicontrol('style','edit','units','normalized','position',[.4 .81 .2 .1],'horizontalalignment','left','callback',{@pressInput});
    
    %Text and edit box for user to input gas temperature 
    comp.tempText = uicontrol('style','text','units','normalized','position',[.7 .85 .2 .1], 'string','Input Temperature (K):','horizontalalignment','left');
    comp.tempEnter = uicontrol('style','edit','units','normalized','position',[.7 .81 .2 .1],'horizontalalignment','left','callback',{@tempInput});
    
    %Funciton call button and display of Z-value (compressibility factor)
    comp.zCalc = uicontrol('style','pushbutton','units','normalized','position',[.35 .5 .3 .1],'string','Calculate Compressibility (Z)','horizontalalignment','left','callback',{@zCalculator});
    comp.zText = uicontrol('style','text','units','normalized','position',[.4 .3 .2 .1], 'string','Z =','horizontalalignment','left');
    comp.zDisp = uicontrol('style','text','units','normalized','position',[.45 .3 .2 .1], 'string',num2str(comp.z),'horizontalalignment','left');
end

function [] = criticalControl(~,~)
    global comp
    value = comp.gasChoice.Value; 
    %Small database of critical pressures and temperatures for some gasses.
    %If gas is not in database, user is prompted to input them manually
    switch value
        case 1 %Air
            comp.Pc = 37.4; %in standard atmospheres (atm)
            comp.Tc = 132.7; %in Kelvins
        case 2 %Nitrogen
            comp.Pc = 33.6;
            comp.Tc = 126.2;
        case 3 %Oxygen
            comp.Pc = 49.8;
            comp.Tc = 154.6;
        case 4 %Carbon Dioxide
            comp.Pc = 72.8;
            comp.Tc = 304.4;
        case 5 %User inputs gas properties
            gasEnter = inputdlg({'Input Critical Pressure (atm):','Input Critical Temperature (K):'},'Gas Properties',[1 35],{'0','0'});
            comp.Pc = str2double(gasEnter(1));
            comp.Tc = str2double(gasEnter(2));
    end
end

function [] = pressInput(~,~)
    global comp
    comp.press = str2double(comp.pressEnter.String);
end

function [] = tempInput(~,~)
    global comp
    comp.temp = str2double(comp.tempEnter.String);
end

%This callback function calculates the compressibility of a gas given its
%temperature, pressure, and specific volume.
function [] = zCalculator(~,~)
    global comp
    R = .08206; % L*atm / K*mol
    v = vanDerWaals();
    comp.z = (comp.press * v)/(R * comp.temp);
    comp.zDisp.String = num2str(comp.z);
end

%This function calculates the specific volume (v) of a gas given its
%temperature and pressure. This is necessary to calculate compressibility.
function[v] = vanDerWaals()
    global comp
    R = .08206; % L*atm / K*mol
    a = 27*R^2*comp.Tc^2/(64*comp.Pc);
    b = R*comp.Tc/(8*comp.Pc);
    C = [comp.press,(comp.press*b + R*comp.temp),a,-(a*b)];
    vcalc = roots(C);
%This function outputs three roots, and only one of them is real. The real
%number is the correct v value.
    for i = 1:3
        if isreal(vcalc(i))
            v = vcalc(i);
        end
    end
end