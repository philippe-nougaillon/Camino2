class TableToXls < ApplicationService
    require 'spreadsheet'
    attr_reader :table
    private :table

    def initialize(table)
      @table = table
    end

    def call
      Spreadsheet.client_encoding = 'UTF-8'
    
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet name: @table.name
      bold = Spreadsheet::Format.new :weight => :bold, :size => 11

      headers = ["Date", "Par", "Projet"]
      headers << @table.fields.pluck(:name).map {|e| e.humanize}

      sheet.row(0).concat headers.flatten
      sheet.row(0).default_format = bold
      
      row_index = 1
      fields_to_export = []
      table.record_index.times do | i |
        index = i + 1
        if table.values.records_at(index).any?
          record = table.values.records_at(index).first
          fields_to_export << [record.created_at, record.user.username, record.try(:todo).try(:fullname)]
          table.fields.each do | field |
            if field.values.records_at(index).first
              fields_to_export << field.values.records_at(index).first.data
            end
          end
        end
        sheet.row(row_index).replace fields_to_export.flatten
        fields_to_export = []
        row_index += 1
      end
      return book

    end

end