function my_lptwrite (port, msg)
% function my_lptwrite (port, msg)
% 
% Slightly eases writing to parallel port
if (nargin==1)
    init=(port==0);
    msg=port;
    port=888;%956;
end
persistent ioObj;
if (init) % Initialize
    %create an instance of the io32 object
    ioObj = io32;
    %initialize the inpoutx64 system driver
    status = io32(ioObj);
    if (status~=0)
        error('LPT-related IO installation failed');
    end
else
    for k=1:length(msg)
        io32(ioObj,port,msg(k)); WaitSecs(0.002); %#ok<NODEF>
        io32(ioObj,port,0); WaitSecs(0.002);
    end
end
