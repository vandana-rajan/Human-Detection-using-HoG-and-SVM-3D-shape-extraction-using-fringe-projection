function p =unwrapping(g)


%% Initialization
[SX SY]=size(g);
MaxQueueSize=SX+SY;%maximum Queue Size
HalfMaxQueueSize=fix(MaxQueueSize/2);%half of MaxQueueSize
MinQualityThresh=0.01;%Minimum quality threshold
m=ones(SX,SY);

a=abs(g);%a=a.*mask; 
p=angle(g);%phase to be unwrapped
L=bwlabel(m);
Lnumber=max(max(L));

Unwrapped=zeros(SX,SY);%to indicate whether a pixel has been unwrapped

Qa=zeros(MaxQueueSize,1);%amplitude (array for quened pixels,AQP) 
Qx=zeros(MaxQueueSize,1);%x coordinate 
Qy=zeros(MaxQueueSize,1);%y coordinate 
Qn=0;%number of queued pixels  

Pa=zeros(SX*SY,1);%amplitude (array for postponed pixels, APP)
Px=zeros(SX*SY,1);%x coordinate 
Py=zeros(SX*SY,1);%y coordinate 
Pn=0;%number of postponed pixels
Un=0; %number of pixels unwrapped 

%% 
for i=1:Lnumber
    %find highest quality
    [start_x start_y]=find(a==max(max(a.*(L==i))),1,'first');
    %push into AQP
    [Qx Qy Qa Qn]=InsertQueue(Qx,Qy,Qa,Qn,start_x,start_y,a(start_x,start_y));
    Unwrapped(start_x,start_y)=1;%seed is taken as unwrapped
    Un=Un+1;%update Un
    
end

%% for each quened pixel, its four neighbors are unwrapped.
while Qn>0 
    %step 3.1: 
    cx=Qx(1);cy=Qy(1);
    
    Qx(1:Qn-1)=Qx(2:Qn);%delete
    Qy(1:Qn-1)=Qy(2:Qn);%delete
    Qa(1:Qn-1)=Qa(2:Qn);%delete
    Qn=Qn-1; 
    
    %push the left neighbor into the AQP or APP
    if cx-1>0 && Unwrapped(cx-1,cy)==0 && m(cx-1,cy)==1 
        %unwrapping the left neighbor
        p(cx-1,cy)=p(cx-1,cy)-round((p(cx-1,cy)-p(cx,cy))/2/pi)*2*pi;
        if a(cx-1,cy)>MinQualityThresh %push into AQP if quality is high
            [Qx Qy Qa Qn]=InsertQueue(Qx,Qy,Qa,Qn,cx-1,cy,a(cx-1,cy));
            if Qn==MaxQueueSize %if AQP reaches preset size, split it
                [Qn,Px,Py,Pa,Pn,MinQualityThresh]= SplitQueue(Qx,Qy,Qa,Qn,Px,Py,Pa,Pn,HalfMaxQueueSize);
            end
        else %push into APP if qualtiy is low
            Pn=Pn+1;Px(Pn)=cx-1;Py(Pn)=cy;Pa(Pn)=a(cx-1,cy);
        end
        Unwrapped(cx-1,cy)=1;%mark this pixel as unwrapped.
        Un=Un+1; %update Un
      
    end
    %push the right neighbor into the AQP or APP
    if cx+1<SX+1 && Unwrapped(cx+1,cy)==0 && m(cx+1,cy)==1 
        p(cx+1,cy)=p(cx+1,cy)-round((p(cx+1,cy)-p(cx,cy))/2/pi)*2*pi;
        if a(cx+1,cy)>MinQualityThresh
            [Qx Qy Qa Qn]=InsertQueue(Qx,Qy,Qa,Qn,cx+1,cy,a(cx+1,cy));
            if Qn==MaxQueueSize
                [Qn,Px,Py,Pa,Pn,MinQualityThresh]= ... 
                    SplitQueue(Qx,Qy,Qa,Qn,Px,Py,Pa,Pn,HalfMaxQueueSize);
            end
        else
            Pn=Pn+1;Px(Pn)=cx+1;Py(Pn)=cy;Pa(Pn)=a(cx+1,cy);
        end
        Unwrapped(cx+1,cy)=1;
        Un=Un+1;
       
    end
    %push the upper neighbor into the AQP or APP
    if cy-1>0 && Unwrapped(cx,cy-1)==0 && m(cx,cy-1)==1 
        p(cx,cy-1)=p(cx,cy-1)-round((p(cx,cy-1)-p(cx,cy))/2/pi)*2*pi;
        if a(cx,cy-1)>MinQualityThresh
            [Qx Qy Qa Qn]=InsertQueue(Qx,Qy,Qa,Qn,cx,cy-1,a(cx,cy-1));
            if Qn==MaxQueueSize
                [Qn,Px,Py,Pa,Pn,MinQualityThresh]= ... 
                    SplitQueue(Qx,Qy,Qa,Qn,Px,Py,Pa,Pn,HalfMaxQueueSize);
            end
        else
            Pn=Pn+1;Px(Pn)=cx;Py(Pn)=cy-1;Pa(Pn)=a(cx,cy-1);
        end
        Unwrapped(cx,cy-1)=1;
        Un=Un+1;
        
    end
    %push the lower neighbor into the AQP or APP
    if cy+1<SY+1 && Unwrapped(cx,cy+1)==0 && m(cx,cy+1)==1 
        p(cx,cy+1)=p(cx,cy+1)-round((p(cx,cy+1)-p(cx,cy))/2/pi)*2*pi;
        if a(cx,cy+1)>MinQualityThresh
            [Qx Qy Qa Qn]=InsertQueue(Qx,Qy,Qa,Qn,cx,cy+1,a(cx,cy+1));
            if Qn==MaxQueueSize
                [Qn,Px,Py,Pa,Pn,MinQualityThresh]= ... 
                    SplitQueue(Qx,Qy,Qa,Qn,Px,Py,Pa,Pn,HalfMaxQueueSize);
            end
        else
            Pn=Pn+1;Px(Pn)=cx;Py(Pn)=cy+1;Pa(Pn)=a(cx,cy+1);
        end
        Unwrapped(cx,cy+1)=1;
        Un=Un+1;
        
    end
    
    %if AQP is empty, copy data from APP
    if Qn==0 && Pn>0
        [Qx,Qy,Qa,Qn,Px,Py,Pa,Pn,MinQualityThresh]= ... 
            Copy2Queue(Qx,Qy,Qa,Qn,Px,Py,Pa,Pn,HalfMaxQueueSize);
    end
end
p=p.*m+(min(min(p.*m))-2*pi).*(1-m);



%% Insert a pixel into AQP
function [Qx, Qy, Qa, Qn]=InsertQueue(Qx,Qy,Qa,Qn,x,y,a)
I=find(Qa(1:Qn)<a,1,'first'); %find its proper inserting point
if isempty(I) %put in the end of AQP
    Qx(Qn+1)=x;
    Qy(Qn+1)=y;
    Qa(Qn+1)=a;
else %inset into AQP
    Qx(I+1:Qn+1)=Qx(I:Qn);
    Qx(I)=x;
    Qy(I+1:Qn+1)=Qy(I:Qn);
    Qy(I)=y;
    Qa(I+1:Qn+1)=Qa(I:Qn);
    Qa(I)=a;
end
Qn=Qn+1;%update Qn


%% Split the Queue if it is too long
function [Qn,Px,Py,Pa,Pn,MinQualityThresh]= ... 
    SplitQueue(Qx,Qy,Qa,Qn,Px,Py,Pa,Pn,HalfMaxQueueSize)
%put second half of AQP into APP
Pa(Pn+1:Pn+Qn-HalfMaxQueueSize)=Qa(HalfMaxQueueSize+1:Qn);
Px(Pn+1:Pn+Qn-HalfMaxQueueSize)=Qx(HalfMaxQueueSize+1:Qn);
Py(Pn+1:Pn+Qn-HalfMaxQueueSize)=Qy(HalfMaxQueueSize+1:Qn);
Pn=Pn+Qn-HalfMaxQueueSize; %update Pn
Qn=HalfMaxQueueSize; %update Qn
MinQualityThresh=Qa(Qn);%Update MinQualityThresh


%% Copy pixels from APP to AQP if AQP is empty
function [Qx,Qy,Qa,Qn,Px,Py,Pa,Pn,MinQualityThresh]= ...
    Copy2Queue(Qx,Qy,Qa,Qn,Px,Py,Pa,Pn,HalfMaxQueueSize)
Cn=min(Pn,HalfMaxQueueSize);%number of pixel to be copied
[temp I]=sort(Pa(1:Pn),'descend'); %sort APP and store in 'temp'
Qa(1:Cn)=temp(1:Cn); %copy to AQP
Qx(1:Cn)=Px(I(1:Cn));
Qy(1:Cn)=Py(I(1:Cn));
Qn=Cn; % update Qn
MinQualityThresh=Qa(Qn); %update MInQualityThresh
Pa(1:Pn-Cn)=temp(Cn+1:Pn); %arrange APP
Px(1:Pn-Cn)=Px(I(Cn+1:Pn));
Py(1:Pn-Cn)=Py(I(Cn+1:Pn));
Pn=Pn-Cn;%update Pn
