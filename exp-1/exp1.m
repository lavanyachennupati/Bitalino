
clear;clc;clear java;
% For Matlab versions previous to 2010, run these lines:
javaaddpath(fullfile('/lib/bluecove-2.1.1-SNAPSHOT.jar'));
javaaddpath(fullfile('/lib'));

%%

mac = '201307010810';
SamplingRate = 100;
analogChannels = [2];
nSamples = 1100;
nCycles = 1;
durationGray = 3;
n = 0;
bit = bitalino();
i = 1;
% Open bluetooth connection with bitalino
bit = bit.open(mac,SamplingRate);
global t;
global sum;
global avgSum;
global light;
pcount = 0;
bit.version();
pause(2);

while 1
    pcount = pcount + 1;
    n = 0;
    if bit.connection
        % get bitalino version
        %start acquisition on channel A4
        bit = bit.start(analogChannels);
        disp('Start Acquisition')
        % read samples
        data = bit.read(nSamples);
        disp('Data read')
        %stop acquisition
        bit.stop();

        disp('CLOSED');
        while n < nSamples
            t(i) = data(6, n+1);
            i = i+1;
            n = n+1;
            set(gcf, 'color', 'white');
            drawnow;
            plot(t), axis([1 nSamples*nCycles 0 50])
            
            grid on
            title('Bitalino Captures');
            xlabel('Number of samples');
            ylabel('Channel readings');
            pause(0.00001)
        end
    end
    if pcount == nCycles
        disp('Done')
        break;
    end
end
bit.close();
 i = 2;
 sum(1)=t(1);
 light = t((SamplingRate*durationGray)/2);
 display(light);
  while i< nSamples 
      
            sum(i)=sum(i-1)+t(i);
            
            if(i>SamplingRate*durationGray)
                sum(i)= (sum(i)-t(i-(SamplingRate*durationGray)));
                avgSum = (sum(i)/(SamplingRate*durationGray));
                display(avgSum);
                if (avgSum==light)
                 display(i/SamplingRate-durationGray);
                 display(i/SamplingRate);
                end
            end
            
            if(i==(SamplingRate*durationGray))
                display(i/SamplingRate);
            end
            
          i=i+1;
    end

%close connection
%bit.close();