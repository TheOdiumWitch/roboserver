local ser = require("serialization");

local configPath = "config.txt";

local promptMap = {
    robotName = "Enter a name for your robot.",
    accountName = "Enter your Roboserver account name.",
    serverIP = "Enter the IP address of your Roboserver.",
    tcpPort = "Enter the TCP port for your Roboserver.",
    posX = "Enter your robot's X coordinate.",
    posY = "Enter your robot's Y coordinate.",
    posZ = "Enter your robot's Z coordinate.",
    orient = "Enter 0 if your robot is facing South, 1 if East, 2 if North, 3 if West."
  };

function readFile(path)
  local file = io.open(path, "r");
  if not file then return nil; end
  local content = file:read("*all");
  file:close();
  return content;
end

function getConfig(filePath)
  local config = {};
  local content = readFile(filePath);
  if content then
    config = ser.unserialize(content);
  end
  return config;
end

function setConfig(configTable, filePath)
  local file = io.open(filePath, "w");
  local configString = ser.serialize(configTable);
  file:write(configString);
  file:close();
  return configString;
end

function setConfigOptions(options, path)
  local config = getConfig(path);
  for key, value in pairs(options) do
    config[key] = value;
  end
  return setConfig(config, path)
end

function readNotEmpty()
  local result = nil;
  local value = io.read();
  if value ~= "" then result = value; end
  return result;
end

function readNewConfigOption(prompt, oldValue)
  print(prompt);
  if oldValue then
    print("Current value: " .. oldValue);
  end
  return readNotEmpty() or oldValue;
end

function readConfigOptions(options)
  local newConfig = {};
  local oldConfig = getConfig(configPath);
  print("Changing configuration. Just press enter to leave a value unchanged.");
  for i, property in pairs(options) do
    newConfig[property] = readNewConfigOption(promptMap[property], oldConfig[property]);
  end
  return setConfig(newConfig, configPath);
end

function easyConfig()
  local newConfig = {};
  local oldConfig = getConfig(configPath);
  local promptOrder = {"robotName", "accountName", "posX", "posY", "posZ", "serverIP", "tcpPort"};
  return readConfigOptions(promptOrder);
end

return {
  get = getConfig,
  set = setConfigOptions,
  easy = easyConfig,
  path = configPath,
};