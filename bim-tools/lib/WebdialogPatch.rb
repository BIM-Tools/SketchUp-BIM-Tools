# Custom WebDialog wrapper that works around problems with WebDialog#set_html
# under OSX after Safari 5.0.6 is installed.
#
# Example is bare bone without any error checking. Expand as you find fit.
class WebDialogPatch < UI::WebDialog

  # @note Safari 5.0.6 made .set_html unusable under OSX because any links to
  #   resources ( Images, CSS, JS ) on the local computer failed to load.
  #   Previously it would work when you specified file:/// but now it is denied.
  #
  # @param [String] html_string
  # @return [Nil]
  def set_html( html_string )
    # Clean up any old temp file.
    cleanup_temp_file()
    # Finalizer is attached to the webdialog so when it gets garbage collected
    # temp file is erased.
    # 
    # The temp filename needs to be different from the last on in order for the
    # html to be loaded. If the name is the same the content is not refreshed.
    #
    # For both the temp directory and temp file handling with better error
    # handling it'd probably best to port `tmpdir.rb` and `tempfile.rb` from
    # the Standard Ruby Library.
    #
    # http://www.ruby-doc.org/stdlib-1.8.6/
    tempdir = File.expand_path( ENV['TMP'] || ENV['TEMP'] || ENV['TMPDIR'] || "/tmp" )
    unique_seed = "#{self.object_id}#{Time.now.to_i}".hash.abs
    filename = "webdialog_#{unique_seed}.html"
    @tempfile = File.join( tempdir, filename )
    cleanup_proc = self.class.cleanup_temp_file( @tempfile.dup )
    ObjectSpace.define_finalizer( self, cleanup_proc )
    # Write the HTML content out to the temp file.
    File.open( @tempfile, 'w' ) { |file|
      file.write( html_string )
    }
    set_file_original( @tempfile )
    nil
  end
  
  # @tempfile is set to `nil` when using #set_file and #set_url so the temp file
  # will be deleted. Since the #set_html wrapper uses #set_file it must be
  # aliased
  unless private_method_defined?( :set_file_original )
    # Prevent redefining in case of script reloading which cause infinite loop.
    alias :set_file_original :set_file
    private :set_file_original
  end
  # @param [String] filename
  # @return [Nil]
  def set_file( filename )
    cleanup_temp_file()
    set_file_original( filename )
  end
  
  # @param [String] url
  # @return [Nil]
  def set_url( url )
    cleanup_temp_file()
    super
  end
  
  # @return [Nil]
  def cleanup_temp_file
    if @tempfile
      ObjectSpace.undefine_finalizer( @tempfile )
      File.delete( @tempfile ) if File.exist?( @tempfile )
    end
    @tempfile = nil
  end
  private :cleanup_temp_file
  
  # @private
  #
  # @see #set_html
  # @see http://www.mikeperham.com/2010/02/24/the-trouble-with-ruby-finalizers/
  #
  # @param [String] filename
  # @return [Proc]
  def self.cleanup_temp_file( filename )
    proc { File.delete( filename ) if File.exist?( filename ) }
  end
  
end # class
