% 本程序用于分析预警系统内选取点数据导出，处理并分析点数据
%% 初始化
clear all
%clc
%% ---------------------第一步：导入形变.csv数据-------------------------
filename = 'D:\001雷达仿真\chenjiang\xingbian\dian327_2_403.csv';
data_dian = csvread(filename,1,1);                %import点数据文件到data中
[column,row] = size(data_dian);                  %计算data中数据的行数
%% 获取时间列
delimiter = ',';
startRow = 2;
%列1: 日期时间 (%{yyyy-MM-dd HH:mm}D)
formatSpec = '%{yyyy-MM-dd HH:mm}D%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
%%根据格式读取数据列
dataarray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
%%关闭文本文件。
fclose(fileID);
%将导入的数组分配给列变量名称
data_date = dataarray{:, 1};
% 对于要求日期序列(datenum)而不是日期时间的代码，请取消注释以下行，以便以 datenum 形式返回导入的日期。
%data_date_num =datenum(data_date);
%清除临时变量
clearvars filename delimiter dataarray startRow formatSpec fileID ans;

%% ---------------------第二步：每个点位整体时间段内的极大值、极小值、平均值-----------------------------
%% 整体分析
%获取每一列数据的最大值及对应的时间
[data_max_row,max_date] = max(data_dian);
%获取每一列数据的最小值及对应的时间
[data_min_row,min_date] = min(data_dian);
%获取每一列数据的平均值
data_mean_row = mean(data_dian);

dateformat = 'yyyy/mm/dd HH:MM';
disp(['自',datestr(data_date(1),dateformat),'到',datestr(data_date(column),dateformat),'止：']);
chart_total = cell(1,7);
for i = 1:row
    chart_total{1,1}(i,1) = 'P';
    chart_total{1,2}(i,1) = i;
end
for i = 1:row
%     disp(['P',num2str(i),'点最大值为：',num2str(data_max_row(i)),'对应时间为：',datestr(data_date(max_date(i)),dateformat)]);
%     disp(['P',num2str(i),'点负向位移最大值为：',num2str(data_min_row(i)),'对应时间为：',datestr(data_date(min_date(i)),dateformat)]);
%     disp(['P',num2str(i),'点平均位移为：',num2str(data_mean_row(i))]);
    chart_total(i,1) = i;%整体分析表第一列为点号
%     chart_total(i,2) = data_max_row(i);%第二列为每个点整列数据的最大值
%     chart_total(i,3) = data_date(max_date(i));%第三列数据为最大值对应的时刻
%     chart_total(i,4) = data_min_row(i);%第四列数据为整列数据的最小值
%     chart_total(i,5) = data_date(min_date(i));%第五列数据为最小值对应的时刻
%     chart_total(i,6) = data_mean_row(i);%第六列数据为整列数据的平均值
    
end


%% ---------------------第三步：每个点位按天分析极大值、极小值、平均值-----------------------------
%% 每天分析最大值以及最小值
%分析整个文档中数据分别属于哪一天
t = datevec(data_date);%将datetime形式转换成向量保存
%获取监测天数date_duration
date_duration = datevec(data_date(column) - data_date(1));
date_duration = date_duration(1,3)+1;
%分天获取数据中分界点存在date_change_column中
ii = 1;
date_change_column = zeros(1,date_duration-1);
for i = 1:column-1
    if t(i,3) == t(i+1,3)
        continue;
    else
        date_change_column(ii) = i+1;
        ii = ii+1;
    end
end
date_change_column = [1 date_change_column column+1];
%获取每一天中的最大值以及最小值及其对应时刻

data_daymax = zeros(date_duration,row);data_daymin = zeros(date_duration,row);
max_daytime = zeros(date_duration,row);min_daytime = zeros(date_duration,row);
data_daymean = zeros(date_duration,row);data_daymeanmax = zeros(date_duration,1);
for i = 1:date_duration
    disp(['自',datestr(data_date(date_change_column(1,i)),dateformat),'到',datestr(data_date(date_change_column(1,i+1)-1),dateformat),'止：']);
    disp(['当日扫描',num2str(date_change_column(1,i+1)-date_change_column(1,i)),'轨数据']);
    disp(['累积扫描',num2str(date_change_column(1,i+1)-1),'轨数据']);
    %获取每一列数据的最大值及对应的时间
    [data_daymax(i,:),max_daytime(i,:)] = max(data_dian(date_change_column(1,i):date_change_column(1,i+1)-1,:));%获取每个时间变化区间内的最大值以及对应的行号
    [data_daymin(i,:),min_daytime(i,:)] = min(data_dian(date_change_column(1,i):date_change_column(1,i+1)-1,:));%获取每个时间变化区间内的最小值以及对应的行号 
    data_daymean(i,:) = mean(data_dian(date_change_column(1,i):date_change_column(1,i+1)-1,:));%获取日平均值
%     for j = 1:row
%         disp(['P',num2str(j),'点最大值为：',num2str(data_daymax(i,j)),'对应时间为：',...
%             datestr(data_date(date_change_column(1,i)-1+max_daytime(i,j)),dateformat)]);
%         disp ([ '最大数据对应第',num2str(date_change_column(1,i)-1+max_daytime(i,j)),'轨数据']);
%         disp(['P',num2str(j),'点最小值为：',num2str(data_daymin(i,j)),'对应时间为：',...
%             datestr(data_date(date_change_column(1,i)-1+min_daytime(i,j)),dateformat)]);
%         disp([ '最小数据对应第',num2str(date_change_column(1,i)-1+min_daytime(i,j)),'轨数据']);
%         disp([ '该点当天形变平均值为：',num2str(data_daymean(i,j))]);   
%     end
%     %获取每一天内取得最大值的点
    data_daymeanmax(i,1) = max(data_daymean(i,1:4));%获取区域1，前4个点中的每一天平均值最大值
    
end
