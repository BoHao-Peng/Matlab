function SaveData(path, name, data, varargin)
    eval(strcat(name, '=', 'data;'));
    clear data;
    save(path, name,varargin{:});
end