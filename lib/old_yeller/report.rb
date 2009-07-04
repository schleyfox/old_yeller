module OldYeller
  class Report
    def initialize
      @template_filename = "#{RAILS_ROOT}/tmp/old_yeller_used_templates.txt"
      @rcov_index_filename = "#{RAILS_ROOT}/coverage/index.html"
      @out_filename = "#{RAILS_ROOT}/dead_code.html"
    end

    def write
      File.open(@out_filename, "w") do |f|
        f.puts "<html><head><title>James Brown is Dead</title></head><body>"
        f.puts "<h1>Old Yeller Code Report</h1>"
        f.puts "<h2>RCov on code usage</h2>"
        f.puts "<p><a href=\"#{@rcov_index_filename}\">Coverage Report</a></p>"
        f.puts "<h2>Unused templates</h2>"
        f.puts "<ul>"
        f.puts unused_templates
        f.puts "</ul>"
        f.puts "</body></html>"
      end
    end

    def unused_templates
      (all_templates - used_templates).map do |l| 
        "<li>#{l}</li>"
      end.join("\n")
    end

    def all_templates
      Dir["#{RAILS_ROOT}/app/views/**/*"].map do |fn|
        File.expand_path(fn)
      end.select do |fn|
        File.file? fn
      end.uniq
    end

    def used_templates
      File.read(@template_filename).split("\n").uniq
    end
  end
end


