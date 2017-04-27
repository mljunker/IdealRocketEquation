function [meanisp] = statictest()
    format shortG
    files    = dir('Group*');
    numfiles = length(files);

    Isp          = zeros(numfiles, 1);
    MaxT         = zeros(numfiles, 1);
    Time_Elapsed = zeros(numfiles, 1);
    Peak_Thrust  = zeros(numfiles, 1);
    File_Names   = cell(1, numfiles);

    for i = 1:numfiles
      fname = files(i).name;
      data = load(fname);
      File_Names{i} = fname;

      % sampling size frequency is 1.652 kHz so time can be computed for the x-axis
      % z is the summation of the two load cells
      time = (1:length(data))./1652;
      time = time(:);
      z    = data(:, 3);

      % finds the minimum index for time
      [mz, min_indicies] = min(z);
      t_end = time(min_indicies);

      % finds the start so it can be integrated
      dz       = diff(z);
      indicies = find(dz > 1);

      % find point where water cuts out in order to correct for sensor screwyness
      min_val = min(z);
      lower_peaks = find(z < 0.6*min_val);

      % this is range of data points for which the rocket is actually firing
      start_point = indicies(1);
      last_peak   = lower_peaks(end);

      % get slope of the line between the start and end point for correction (both should be at zero)
      x1   = start_point;    x2 = last_peak;
      y1   = z(start_point); y2 = z(last_peak);
      m    = (y2 - y1) / (x2 - x1);
      line = @(x) z(start_point) + m.*(x - x1);

      % subtract this from the relevant section of the line so that the start and end points are both zero
      % and truncate the data since this is the only section we care about
      span = start_point:last_peak;
      z    = z(span) - line(span)';
      time = time(span);

%       % plot things
%       figure; hold on;
%       plot(time, z);
%       plot(time(1), z(1), 'go')
%       plot(time(end),   z(end),   'ro')
%       xlabel('Time, t [seconds]');
%       ylabel('Thrust, F [Newtons]');

      % integrate the force curve for total impulse
      impulse = trapz(time, z);

      % divide by weight of propellant for specific impulse
      Isp(i)          = impulse./(9.81);
      MaxT(i)         = Isp(i).*(1000/time(i)).*8.91;
      Time_Elapsed(i) = time(end) - time(1);
      Peak_Thrust(i)  = max(z);

      % should give the standard deviation
      val = std2(z);
      % population is 12000
      n = 12000;

      x_bar = val./sqrt(n);
    end

    % for 95% confidence we use 1.96*SEM as a bounding parameter
    SEM = @(N) std(Isp) ./ sqrt(N);

%     figure;
%     plot(1:100, SEM(1:100))
%     title('SEM vs Number of Datasets')
%     ylabel('SEM');
%     xlabel('Datasets');

    % SEM examples
    % std_dev = std(Isp);
    % disp((1.96*std_dev/0.1)^2);
    % disp((2.24*std_dev/0.1)^2);
    % disp((2.58*std_dev/0.1)^2);
    % disp((1.96*std_dev/0.01)^2);
    % disp((2.24*std_dev/0.01)^2);
    % disp((2.58*std_dev/0.01)^2);

    %     %  print out tables1
    %     fprintf('\n');
    %     fprintf('%28s %10s %15s %16s \n', 'Name', 'Isp [s]', 'Peak Thrust [N]', 'Elapsed Time [s]');
    %     for i = 1:numfiles
    %       fname = File_Names{i};
    %       isp = Isp(i);
    %       pk_thr = Peak_Thrust(i);
    %       elapsed = Time_Elapsed(i);
    %       fprintf('%28s %10.2f %15.0f %16.2f\n', fname, isp, pk_thr, elapsed);
    %     end
    meanisp = mean(Isp);
    %     fprintf('means: ISP %.2f, Peak Thrust %.0f, Elapsed Time %.2f\n', mean(Isp), mean(Peak_Thrust), mean(Time_Elapsed));
    %     fprintf('sigma ISP %.2f, sigma Peak Thrust %.0f, sigma Elapsed Time %.2f\n', std(Isp), std(Peak_Thrust), std(Time_Elapsed));
end