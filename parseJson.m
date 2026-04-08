function [data] = parseJson(local_json_name)
% @brief 用于解析本地json文件
% @param local_json_name 为本地json文件名
% @return 返回解析后的json结构体

fid = fopen(local_json_name, "r");
if fid == -1
    error('无法打开 JSON 文件：%s', local_json_name);
end

json_content = fread(fid, '*char')'; % 读取为字符数组并转置
fclose(fid);

data = jsondecode(json_content);

end