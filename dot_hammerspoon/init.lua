hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

function applicationWatcher(appName, eventType, appObject)
	print(appName, eventType, appObject)
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

function reloadConfig(paths, force)
	appWatcher:stop()
	appWatcher = nil
end
