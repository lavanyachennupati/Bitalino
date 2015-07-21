
clear;clc;clear java;
% For Matlab versions previous to 2010, run these lines:
javaaddpath(fullfile('/lib/bluecove-2.1.1-SNAPSHOT.jar'));
javaaddpath(fullfile('/lib'));

%%
%mac address of the bitalino board
mac = '201307010810';
%number if samples collected every second.
SamplingRate = 100;
%respective "A-1" value of the channel/s data to be captured.
analogChannels = [2];
%total number of samples
nSamples = 1500;
%duration of the gray slide in the presentation used.
durationGray = 3;
%duration of each part of the video 
durationVideo = 5;
bit = bitalino();
n = 0;
i = 1;
global t;
global sum;
global avgSum;
global light;
global a;
global b;
global begin;
global finish;
global count;
global noOfGray;
global bcount;
global flag;

%noOfGray is the number of times a gray slide would occur in one video
%slide
noOfGray = floor(durationVideo/durationGray); 
%number of samples in a video that are not a interger of the gray slide
%samples
bcount= ((durationVideo*SamplingRate)-(noOfGray*durationGray*SamplingRate));
count=0;
% Open bluetooth connection with bitalino
bit = bit.open(mac,SamplingRate);

bit.version();
pause(2);

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
        %plot the data collected for nsamples
        while n < nSamples
            %all the data from the analog channels is stored from 6
            %onwards. The first 5 are reserved.
            t(i) = data(6, n+1);
            i = i+1;
            n = n+1;
            set(gcf, 'color', 'white');
            drawnow;
            plot(t), axis([1 nSamples 0 50])
            
            grid on
            title('Bitalino Captures');
            xlabel('Number of samples');
            ylabel('Channel readings');
            pause(0.00001)
        end
    end

        disp('Done')

bit.close();
 i = 1;
 sum=0;
 
 %The first sample where the powerpoint first slide starts is marked.
 %The lux is covered and is opened excatly when the ppt starts.
 % 3 is just used as, even if covered it wont be a perfect zero.
  while(i<nSamples)
      if(t(i)>3)
      break; 
      end;
      i=i+1;
  end;
  
  %The lux value of the mid gray slide stored for comaprision later.
  light = t(i+((SamplingRate*durationGray)/2));
  a=0;
  b=0;
  %flag is used to check if at the current time it is a gray slide or video
  %slide. gray slide:flag-0
  flag=0;
  
  %Average value of gray slide duration number of samples collected every time. 
  %If this is equal to the light term, then these samples are from the gray
  %slide.
  %Hence the start of these samples marks end of a previous video and end of it
  %start of the next video.
  %When it is a video with not the exact number of grayslide times . Then
  %the remaining extra samples average ignored.
  
  while (i< nSamples) 
      
            if(a ~= noOfGray)
            sum=sum+t(i);
            count = count+1;
            end;
            
            if(a==noOfGray)
                b = b+1;
                if(b==bcount)
                    a=0;
                    b=0;
                    finish=i/SamplingRate;
                    display(finish);
                    flag=0;
                end;
            end;
            
            if(a ~= noOfGray)
            if(count == SamplingRate*durationGray)
                avgSum = sum/(SamplingRate*durationGray);
                %display(avgSum);                
                count=0;
                sum=0;
                avgSum=0;
                if(flag==1)
                    a=a+1;
                end;
                
                if(light-0.5<avgSum<light+0.5)
                 begin=i/SamplingRate;
                 display(begin);  
                 flag=1;
                end;
           
            end;
            end;  
            
          i=i+1;
  end;

%close connection
%bit.close();