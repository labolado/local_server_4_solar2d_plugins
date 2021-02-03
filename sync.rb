require 'fileutils'
require 'work_queue'
require 'tempfile'
require 'open-uri'
require 'curb'
require 'tmpdir' # Not needed if you are using rails.

require 'open3'
require 'pty'

localServer = "http://127.0.0.1:10980/"
urls = {

	"plugin.android.assets" => {
		"android" => "https://github.com/labolado/solar2d_plugin.android.assets/releases/download/v1/2020.3620-android.tgz"
	},
	"plugin.google.iap.billing.plus" => {
		"android" => "https://github.com/labolado/plugin.google.iap.billing.plus/releases/download/v2/2017.3105-android.tgz"
	},
	"plugin.zip" => {
		"android" => "https://github.com/coronalabs/com.coronalabs-plugin.zip/releases/download/v2/2017.3037-android.tgz",
		"iphone" => "https://github.com/coronalabs/com.coronalabs-plugin.zip/releases/download/v2/2020.3590-iphone.tgz",
		"iphone-sim" => "https://github.com/coronalabs/com.coronalabs-plugin.zip/releases/download/v2/2017.3037-iphone-sim.tgz",
		"macos" => "https://github.com/coronalabs/com.coronalabs-plugin.zip/releases/download/v2/2017.3037-mac-sim.tgz",
		# "win32" => "https://github.com/coronalabs/com.coronalabs-plugin.zip/releases/download/v2/2017.3037-win32-sim.tgz",
		"appletvos" => "https://github.com/coronalabs/com.coronalabs-plugin.zip/releases/download/v2/2017.3037-appletvos.tgz",
	},
	"plugin.bit" => {
		"android" => "https://github.com/coronalabs/com.coronalabs-plugin.bit/releases/download/v2/2013.2584-android.tgz",
		"iphone" => "https://github.com/coronalabs/com.coronalabs-plugin.bit/releases/download/v2/2020.3590-iphone.tgz",
		"iphone-sim" => "https://github.com/coronalabs/com.coronalabs-plugin.bit/releases/download/v2/2013.2584-iphone-sim.tgz",
		"macos" => "https://github.com/coronalabs/com.coronalabs-plugin.bit/releases/download/v2/2013.2584-mac-sim.tgz",
		"win32" => "https://github.com/coronalabs/com.coronalabs-plugin.bit/releases/download/v2/2013.2584-win32-sim.tgz",
		"appletvos" => "https://github.com/coronalabs/com.coronalabs-plugin.bit/releases/download/v2/2013.2584-appletvos.tgz",
		"web" => "https://github.com/coronalabs/com.coronalabs-plugin.bit/releases/download/v2/2013.2584-web.tgz",

	},

	"plugin.storage" => {
		"android" => "https://github.com/labolado/solar2d-plugin_storage/releases/download/v3/2020.3620-android.tgz",
		"iphone" => "https://github.com/labolado/solar2d-plugin_storage/releases/download/v3/2020.3620-iphone.tgz"
	},

	"plugin.social.share" => {
		"android" => "https://github.com/labolado/solar2d-plugin.social.share/releases/download/v1/2020.3620-android.tgz",
		"iphone" => "https://github.com/labolado/solar2d-plugin.social.share/releases/download/v1/2020.3620-iphone.tgz",
		"iphone-sim" => "https://github.com/labolado/solar2d-plugin.social.share/releases/download/v1/2020.3620-iphone-sim.tgz"
	},

	"plugin.google.iap.v3" => {
		"android" => "https://github.com/coronalabs/com.coronalabs-plugin.google.iap.v3/releases/download/v1/2017.3105-android.tgz"
	},

	"CoronaProvider.native.popup.social" => {
		"android" => "https://github.com/coronalabs/com.coronalabs-CoronaProvider.native.popup.social/releases/download/v1/2013.1164-android.tgz",
		"mac" => "https://github.com/coronalabs/com.coronalabs-CoronaProvider.native.popup.social/releases/download/v1/2013.1164-mac-sim.tgz"
	},


	"plugin.amazon.iap" => {
		"android-kindle" => "https://github.com/coronalabs/com.coronalabs-plugin.amazon.iap/releases/download/v2/2013.2731-android.tgz",
	},
	"plugin.reviewPopUp" => {
		"iphone" => "https://github.com/solar2d/tech.scotth-plugin.reviewPopUp/releases/download/v1/2016.3065-iphone.tgz",
		"iphone-sim" => "https://github.com/solar2d/tech.scotth-plugin.reviewPopUp/releases/download/v1/2016.3065-iphone-sim.tgz"
	}

	# :android => {
	# 	"plugin.zip" => "",
	# 	"plugin.bit" => "",
	# 	"plugin.google.iap.v3" => "",
	# 	"CoronaProvider.native.popup.social" => "https://github.com/coronalabs/com.coronalabs-CoronaProvider.native.popup.social/releases/download/v1/2013.1164-android.tgz",
	# 	"plugin.storage" => "https://github.com/labolado/solar2d-plugin_storage/releases/download/v2/2020.3620-android.tgz"

	# },
	# :iphone => {
	# 	"plugin.zip" => "",
	# 	"plugin.bit" => "https://github.com/coronalabs/com.coronalabs-plugin.bit/releases/download/v2/2020.3590-iphone.tgz",
	# 	"plugin.storage" => "https://github.com/labolado/solar2d-plugin_storage/releases/download/v2/2020.3620-iphone.tgz",
	# },
	# "android-kindle" => {
	# 	"plugin.amazon.iap" => "https://github.com/coronalabs/com.coronalabs-plugin.amazon.iap/releases/download/v2/2013.2731-android.tgz"
	# }
}

	def  execShell(shellCmd, successText, errorText)
				 
		result = ""
		begin
		  PTY.spawn( shellCmd ) do |stdout, stdin, pid|
		    begin
		      stdout.each { |line| 
		      	#print line
		      	result = result + line	
		      }

		    rescue Errno::EIO
		    end
		  end
		   
		rescue PTY::ChildExited
		  puts "The child process exited!"
		  return false
		end

		if errorText != nil 
			errorText = [errorText] if !errorText.kind_of?(Array)
			hasError = false
			errorText.each do |t|
				if t != "" && result.index(t) != nil
					hasError = true
					break
				end
			end

			if hasError
				puts("失败，发现错误标签#{errorText}:#{shellCmd}")
			 	return false
			end
		end
	

				 
		 # if errorText != nil && errorText != "" && result.index(errorText) != nil
		 # 	#puts result
		 # 	puts("失败，发现错误标签#{errorText}:#{shellCmd}")
		 # 	return false
		 # end 

		 if successText != nil && successText != "" && result.index(successText) == nil
		 	#puts result
		 	puts("失败，未发现成功标签#{successText}:#{shellCmd}")
		 	return false
		 end 

		return true
	end
 

def red(str)
return "\033[31m#{str}\033[0m"
end

def downloadFile(url, fileName)
 	return execShell("curl -v -L #{url}  --output #{fileName}", 'HTTP/2 200', nil)
end



fileNames = {}
text =""
urls.keys.each do |key|
	text += "[\"#{key}\"] = { \r\n"
	text +=  "\tpublisherId = \"com.coronalabs\",\r\n"
	text +=  "\tsupportedPlatforms = {\r\n"
	items = urls[key]
	items.keys.each do |platform|
		url = items[platform]
				fname = url.split('/')[-1]
		newUrl = "#{localServer}plugins/#{platform}/#{key}/#{fname}"
		#newUrl = "https://github.91chifun.workers.dev//#{url}"
		text +=  "\t\t[\"#{platform}\"] = {url = \"#{newUrl}\"},\r\n"

		fileNames[url] = {:dir =>"/plugins/#{platform}/#{key}",  :name => "#{fname}"}
		 
	end
	text +=  "\t}\r\n"
	text +=  "},\r\n"
end

current_dir =  File.expand_path File.dirname(__FILE__)

File.write("plugins.txt", text)
puts text
semaphore = Mutex.new

wq = WorkQueue.new 20


urls.keys.each do |key|
	items = urls[key]
	items.keys.each do |platform|
		url = items[platform]
		fdata = fileNames[url]
		FileUtils.mkdir_p(current_dir + fdata[:dir]) if !File.exists?(current_dir + fdata[:dir])
		wq.enqueue_b { 
			ret = downloadFile("https://github.91chifun.workers.dev//" + url, current_dir + fdata[:dir] + "/" + fdata[:name]) 
			
			if ret
				puts("#{url} download ok ")  
			else
				puts(red("#{url} download failed")) 
			end

		}
	end
end

wq.join
