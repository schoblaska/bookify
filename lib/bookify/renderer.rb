class Bookify::Renderer
  MARKDOWN_CONVERTER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, tables: true)

  attr_accessor :input_file, :output_file, :layout, :columns, :input_text

  def self.from_args(args)
    if ["-l", "--landscape"].include?(args[0])
      args.shift
      layout = :landscape
      columns = 3
    else
      layout = :portrait
      columns = 2
    end

    input_file = args[0]
    output_file = args[1] || input_file.split("/").last.gsub(/\.\w+/, ".pdf")

    new(layout: layout, columns: columns, input_file: input_file, output_file: output_file)
  end

  def initialize(layout: :landscape, columns: 2, output_file:, input_file: nil, input_text: nil)
    @layout = layout
    @columns = columns
    @output_file = output_file
    @input_file = input_file
    @input_text = input_text
  end

  def render
    Prawn::Document.generate(output_file, margin: 50, page_layout: layout) do |pdf|
      font_path = "#{File.dirname(__FILE__)}/../../fonts"

      pdf.font_families["Book Antiqua"] = {
        normal: {file: "#{font_path}/BookAntiqua.ttf"},
        bold: {file: "#{font_path}/BookAntiqua-Bold.ttf"},
        italic: {file: "#{font_path}/BookAntiqua-Italic.ttf"},
        bold_italic: {file: "#{font_path}/BookAntiqua-BoldItalic.ttf"},
      }

      pdf.fill_color "000000"
      pdf.stroke_color "333333"
      pdf.line_width(0.5)
      pdf.default_leading 0.5

      pdf.column_box [0, pdf.cursor], columns: columns, width: pdf.bounds.width do
        doc.children.each { |c| Bookify::Node.render(c, pdf) }
      end
    end
  end

  private

  def markdown
    @markdown ||= (input_text || File.read(input_file))
  end

  def doc
    @doc ||= Nokogiri::HTML(html)
  end

  def html
    @html ||= MARKDOWN_CONVERTER.render(markdown)
  end
end
