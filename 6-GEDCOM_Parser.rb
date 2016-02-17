require 'rexml/document'
include REXML

doc = Document.new
doc.add_element 'gedcom'

# chances are this might be easier and more elegant with an array, but
# wanted to see how far I would get using a hash...
levels = {-1 => doc.root}

File.open('quiz_data/royal92.ged').each_line do |line|
  /^(?<level>\d+)\s+(?<tag>\w+)\s*(?<data>.*)/ =~ line
  /^(?<level>\d+)\s+(?<id>@\w+@)\s*(?<type>.*)/ =~ line unless tag
  level = Integer(level)

  if levels.size - 1 == level
    # we do not need to traverse up the tree
    parent_node = levels[level - 1]
  elsif levels.size - 1 > level
    # time to do a bit of climbing
    parent_node = levels[level - 1]
    levels.select! {|k, v| k < level}
  else
    raise "Malformed data or we have a bug!"
  end

  new_node = parent_node.add_element(tag.downcase).add_text(data) if tag
  new_node = parent_node.add_element(type.downcase, {'id' => id}) if id
  levels[level] = new_node
end

doc.write(File.open('output.xml', 'w'), 2)
