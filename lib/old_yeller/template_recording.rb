module OldYeller
  module TemplateRecording
    def set_extension_and_file_name_with_recording(use_full_path)
      r = set_extension_and_file_name_without_recording(use_full_path)
      @@template_list.puts filename
      r
    end

    def self.included(base)
      base.class_eval do
        @@template_list = File.open(
          "#{RAILS_ROOT}/tmp/old_yeller_used_templates.txt", "w")
        
        alias_method_chain :set_extension_and_file_name, :recording
      end
    end
  end
end
