require "test/unit"
require "rexml/document"

require_relative "../../lib/asker/data/concept"
require_relative "../../lib/asker/data/world"

class ConceptTest < Test::Unit::TestCase
  def setup
    string_data = get_xml_data
    @concept = []
    @context = [ "character", "starwars"]
    root_xml_data=REXML::Document.new(string_data)
    root_xml_data.root.elements.each do |xml_data|
      if xml_data.name=="concept" then
        @concept << Concept.new(xml_data, "input.haml", "en", @context)
      end
    end
  end

  def test_id
    assert_equal @concept[0].id + 1, @concept[1].id
  end

  def test_names
    assert_equal "obiwan" , @concept[0].name

    assert_equal 2        , @concept[0].names.size
    assert_equal "obiwan" , @concept[0].names[0]
    assert_equal "obi-wan", @concept[0].names[1]

    assert_equal 1        , @concept[1].names.size
    assert_equal "yoda"   , @concept[1].name
    assert_equal "yoda"   , @concept[1].names[0]
  end

  def test_type
    assert_equal "text", @concept[0].type
    assert_equal "text", @concept[1].type
  end

  def test_tags
    lTags = [ 'jedi', 'teacher', 'annakin', 'skywalker', 'pupil', 'quigon-jinn']
    assert_equal lTags.size, @concept[0].tags.size
    assert_equal lTags, @concept[0].tags

    lTags = [ 'teacher', 'jedi' ]
    assert_equal lTags.size, @concept[1].tags.size
    assert_equal lTags, @concept[1].tags
  end

  def test_context
    assert_equal @context.size, @concept[0].context.size
    assert_equal @context,      @concept[0].context

    assert_equal @context.size, @concept[1].context.size
    assert_equal @context,      @concept[1].context
  end

  def test_texts
    assert_equal 2, @concept[0].texts.size
    def_text="Jedi, teacher of Annakin  Skywalker"
    assert_equal def_text, @concept[0].text
    assert_equal def_text, @concept[0].texts[0]

    assert_equal 4, @concept[1].texts.size
    def_text= [ "Jedi, teacher of all jedis" ,
                "The Main Teacher of Jedi and one of the most important members of the Main Jedi Council, in the last days of Star Republic."  ,
                "He has exceptional combat abilities with light sable, using acrobatics tecnics from Ataru." ,
                "He was master of all light sable combat styles and was considered during years as a Sword Master."
              ]
    assert_equal def_text[0], @concept[1].text
    assert_equal def_text[0], @concept[1].texts[0]
    assert_equal def_text[1], @concept[1].texts[1]
  end

  def test_tables
    name = "$attribute$value"
    for i in 0..1
      assert_equal 1,     @concept[i].tables.size
      assert_equal name,  @concept[i].tables[0].name
      assert_equal false, @concept[i].tables[0].sequence?
      assert_equal 0,     @concept[i].tables[0].sequence.size
      assert_equal [],    @concept[i].tables[0].sequence
      assert_equal 2,     @concept[i].tables[0].fields.size
      assert_equal ["attribute","value"], @concept[i].tables[0].fields
    end
  end

  def test_neighbors
    assert_equal 0        , @concept[0].neighbors.size
    assert_equal 0        , @concept[1].neighbors.size

    World.new(@concept) # Add neigbours to @concepts

    assert_equal 1        , @concept[0].neighbors.size
    assert_equal "yoda"   , @concept[0].neighbors[0][:concept].name
    assert_equal 44.44444444444444 , @concept[0].neighbors[0][:value]
    assert_equal 1        , @concept[1].neighbors.size
    assert_equal "obiwan" , @concept[1].neighbors[0][:concept].name
    assert_equal 80.0     , @concept[1].neighbors[0][:value]
  end

  def test_calculate_nearest_to_concept
    assert_equal 44.44444444444444, @concept[0].calculate_nearness_to_concept(@concept[1])
    assert_equal 80.0             , @concept[1].calculate_nearness_to_concept(@concept[0])
  end

  def test_rows
    lRows=[ [ 'race', 'human' ],
             [ 'laser sabel color', 'green'],
             [ 'hair color', 'red' ]
            ]
    assert_equal lRows.size, @concept[0].tables[0].rows.size
    for i in 0..2
      assert_equal lRows[i], @concept[0].tables[0].rows[i]
    end
  end


  def get_xml_data
    string_data = <<EOF
    <map lang='en' context='character, starwars' version='1'>

      <concept>
        <names>obiwan, obi-wan</names>
        <tags>jedi, teacher, annakin, skywalker, pupil, quigon-jinn</tags>
        <def>Jedi, teacher of Annakin  Skywalker</def>
        <def>Jedi, pupil of Quigon-Jinn</def>
        <table fields='attribute, value'>
          <row>
            <col>race</col>
            <col>human</col>
          </row>
          <row>
            <col>laser sabel color</col>
            <col>green</col>
          </row>
          <row>
            <col>hair color</col>
            <col>red</col>
          </row>
        </table>
      </concept>

      <concept>
        <names>yoda</names>
        <tags>teacher, jedi</tags>
        <def>Jedi, teacher of all jedis</def>
        <def>The Main Teacher of Jedi and one of the most important members of the Main Jedi Council, in the last days of Star Republic.</def>
        <def>He has exceptional combat abilities with light sable, using acrobatics tecnics from Ataru.</def>
        <def>He was master of all light sable combat styles and was considered during years as a Sword Master.</def>
        <table fields='attribute, value'>
          <row>
            <col>laser sabel color</col>
            <col>green</col>
          </row>
          <row>
            <col>hair color</col>
            <col>white</col>
          </row>
          <row>
            <col>skin color</col>
            <col>green</col>
          </row>
          <row>
            <col>high</col>
            <col>65 centimetres</col>
          </row>
        </table>
      </concept>
    </map>
EOF
    string_data
  end
end
