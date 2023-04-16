% load blocking rate list files 
load("blocking_rate_FA_average_list.mat");
load("blocking_rate_FA_average_list_nonuniform_1.mat");
load("blocking_rate_FA_average_list_nonuniform_2.mat");
load("blocking_rate_LODA_average_list.mat");
load("blocking_rate_LODA_average_list_nonuniform_1.mat");
load("blocking_rate_LODA_average_list_nonuniform_2.mat");
load("blocking_rate_BDCL_average_list.mat");
load("blocking_rate_BDCL_average_list_nonuniform_1.mat");
load("blocking_rate_BDCL_average_list_nonuniform_2.mat");

% specify x-axis coordinates
traffic_load_list_FA = 100:5:200;
traffic_load_list_LODA = 100:10:200;
traffic_load_list_BDCL = 100:10:200;
traffic_load_ratio_list_FA = 0:0.1:1.5; 
traffic_load_ratio_list_LODA = 0:0.15:1.5;
traffic_load_ratio_list_BDCL = 0:0.15:1.5;

% plot the uniform distribution case
figure
p1=plot(traffic_load_list_FA, blocking_rate_FA_average_list, '-');
p1.Marker='.';
hold on
p2=plot(traffic_load_list_LODA, blocking_rate_LODA_average_list, '-');
p2.Marker='.';
hold on
p3=plot(traffic_load_list_BDCL, blocking_rate_BDCL_average_list, '-');
p3.Marker='.';

% add title and axis labels
title('Blocking comparison: uniform traffic')
xlabel('traffic load (calls/hour)')
ylabel('blocking probability')

% add ticks to the x and y axis
xticks(100:20:200)
yticks(0:0.05:0.20)

% add legend
legend('FA and Erlang B', 'LODA', 'BDCL')

% plot the nonuniform distribution 1 case
figure
p1=plot(traffic_load_ratio_list_FA, blocking_rate_FA_average_list_nonuniform_1, '-');
p1.Marker='.';
hold on
p2=plot(traffic_load_ratio_list_LODA, blocking_rate_LODA_average_list_nonuniform_1, '-');
p2.Marker='.';
hold on
p3=plot(traffic_load_ratio_list_BDCL, blocking_rate_BDCL_average_list_nonuniform_1, '-');
p3.Marker='.';

% add title and axis labels
title('Blocking comparison: nonuniform traffic 1')
xlabel('percentage lncrease of traffic load')
ylabel('blocking probability')

% add ticks to the x and y axis
xticks(0:10:140)
yticks(0:0.1:0.40)

% add legend
legend('FA', 'LODA', 'BDCL')

% plot the nonuniform distribution 2 case
figure
p1=plot(traffic_load_ratio_list_FA, blocking_rate_FA_average_list_nonuniform_2, '-');
p1.Marker='.';
hold on
p2=plot(traffic_load_ratio_list_LODA, blocking_rate_LODA_average_list_nonuniform_2, '-');
p2.Marker='.';
hold on
p3=plot(traffic_load_ratio_list_BDCL, blocking_rate_BDCL_average_list_nonuniform_2, '-');
p3.Marker='.';

% add title and axis labels
title('Blocking comparison: nonuniform traffic 2')
xlabel('percentage lncrease of traffic load')
ylabel('blocking probability')

% add ticks to the x and y axis
xticks(0:10:140)
yticks(0:0.1:0.40)

% add legend
legend('FA', 'LODA', 'BDCL')


