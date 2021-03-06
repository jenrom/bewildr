#Copyright (c) 2010, Nathaniel Ritmeyer. All rights reserved.

module Bewildr
  class Element
    attr_reader :automation_element
    attr_reader :control_type
    
    def initialize(input)
      @automation_element = input
      case input
      when System::Windows::Automation::AutomationElement
        set_control_type
        build_element
      when nil then @control_type = :non_existent
      else raise Bewildr::BewildrInternalError, "Can only initialize an element with a nil or a Sys::Win::Auto::AE[C], not a #{input.class}"
      end
    end

    def name
      existence_check
      @automation_element.current.name.to_s
    end

    def automation_id
      existence_check
      @automation_element.current.automation_id.to_s
    end

    def exists?
      return false if @control_type == :non_existent
      begin
        @automation_element.current.bounding_rectangle
        return true
      rescue System::Windows::Automation::ElementNotAvailableException, TypeError => e
        return false
      end
    end
    alias :exist? :exists?

    def contains?(condition_hash)
      get(condition_hash).exists?
    end
    alias :contain? :contains?

    def enabled?
      existence_check
      @automation_element.current.is_enabled
    end

    def wait_for_existence_of(condition_hash)
      Timeout.timeout(30) do
        sleep 0.1 until contains?(condition_hash)
      end
      get(condition_hash)
    end

    def wait_for_non_existence_of(condition_hash)
      Timeout.timeout(30) do
        sleep 0.1 unless contains?(condition_hash)
      end
    end

    def focus
      @automation_element.set_focus
    end

    def scrollable?
      return false unless @automation_element.get_supported_patterns.collect {|pattern| pattern.programmatic_name.to_s }.include?("ScrollPatternIdentifiers.Pattern")
      vertically_scrollable
    end

    #:id => "id"
    #:name => "bob"
    #:type => :button
    #:scope => :children / :descendants
    #:how_many => :first / :all
    def get(condition_hash)
      existence_check
      condition = Finder.condition_for(condition_hash)
      scope = Finder.scope_for(condition_hash)
      how_many = Finder.how_many_for(condition_hash)
      
      result = @automation_element.send how_many, scope, condition
      case result
      when System::Windows::Automation::AutomationElement, nil then return Bewildr::Element.new(result)
      when System::Windows::Automation::AutomationElementCollection
        c_array_list = System::Collections::ArrayList.new(result)
        element_array = c_array_list.to_array.to_a
        case
        when element_array.size == 0 then return Bewildr::Element.new(nil)
        #when element_array.size == 1 then return Bewildr::Element.new(element_array.first)
        when element_array.size > 0 then return element_array.collect {|element| Bewildr::Element.new(element) }
        end
      end
    end

    #add "children/child" and "descendants/descendant" methods

    def children
      get({:scope => :children}).collect {|element| Bewildr::Element.new(element)}
    end

    def click
      CLICKR.click(clickable_point)
    end

    def double_click
      CLICKR.double_click(clickable_point)
    end

    def right_click
      CLICKR.right_click(clickable_point)
    end

    private

    def existence_check
      raise Bewildr::ElementDoesntExist unless exists?
    end

    def clickable_point
      existence_check
      Timeout.timeout(30) do
        current_clickable_point = nil
        begin
          current_clickable_point = @automation_element.get_clickable_point
        rescue System::Windows::Automation::NoClickablePointException
          retry
        end
        return current_clickable_point
      end
    end

    def prepare_element
      load_all_items_hack if scrollable?
    end

    def set_control_type
      @control_type = Bewildr::ControlType.symbol_for_enum(@automation_element.current.control_type)
    end

    #list of control types comes from http://msdn.microsoft.com/en-us/library/ms750574.aspx
    def build_element
      case @control_type
      when :button
      when :calendar
      when :check_box
        extend Bewildr::ControlPatterns::TogglePattern
      when :combo_box
        extend Bewildr::ControlTypeAdditions::ComboBoxAdditions
      when :custom
        build_custom_control_type
      when :data_grid
        extend Bewildr::ControlTypeAdditions::DataGridAdditions
      when :data_item
      when :document
        extend Bewildr::ControlTypeAdditions::DocumentAdditions
      when :edit
        extend Bewildr::ControlPatterns::ValuePattern
      when :group
      when :header
      when :header_item
      when :hyperlink
        extend Bewildr::ControlTypeAdditions::TextAdditions
      when :image
      when :list
        extend Bewildr::ControlTypeAdditions::ListAdditions
      when :list_item
        extend Bewildr::ControlPatterns::SelectionItemPattern
      when :menu
        extend Bewildr::ControlTypeAdditions::MenuAdditions
      when :menu_bar
      when :menu_item
        extend Bewildr::ControlTypeAdditions::MenuItemAdditions
      when :pane
      when :progress_bar
        extend Bewildr::ControlPatterns::RangeValuePattern
      when :radio_button
        extend Bewildr::ControlPatterns::SelectionItemPattern
      when :scroll_bar
      when :seperator
      when :slider
        extend Bewildr::ControlPatterns::RangeValuePattern
      when :spinner
      when :split_button
      when :status_bar
      when :tab
        extend Bewildr::ControlTypeAdditions::TabAdditions
      when :tab_item
        extend Bewildr::ControlPatterns::SelectionItemPattern
      when :table
      when :text
        extend Bewildr::ControlTypeAdditions::TextAdditions
      when :thumb
      when :title_bar
      when :tool_bar
      when :tool_tip
      when :tree
        extend Bewildr::ControlTypeAdditions::TreeAdditions
      when :tree_item
        extend Bewildr::ControlTypeAdditions::TreeItemAdditions
      when :window
        extend Bewildr::ControlTypeAdditions::WindowAdditions
      end

      #add scrolling capability if relevant - TODO: this ugliness will be fixed later
      if @automation_element.get_supported_patterns.collect {|pattern| pattern.programmatic_name.to_s }.include?("ScrollPatternIdentifiers.Pattern")
        extend Bewildr::ControlTypeAdditions::ScrollAdditions
      end
    end

    #TODO: replace build_element to use something similar to what's below, but
    #make it smarter
    def build_custom_control_type
      @automation_element.get_supported_patterns.each do |supported_pattern|
        case supported_pattern.programmatic_name.to_s
        when "ValuePatternIdentifiers.Pattern" then extend Bewildr::ControlPatterns::ValuePattern
        when "TableItemPatternIdentifiers.Pattern" then extend Bewildr::ControlPatterns::TableItemPattern
        end
      end
    end
  end
end
