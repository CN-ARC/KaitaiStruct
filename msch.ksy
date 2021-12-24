meta:
  id: msch
  endian: be
  file-extension: msch
seq:
  - id: header
    type: header
  - id: body
    process: zlib
    size-eos: true
    type: body
types:
  header:
    seq:
      - id: magic
        contents: 'msch'
      - id: ver
        type: u1
        enum: known_version
  body:
    seq:
      - id: width
        type: s2
      - id: height
        type: s2
      - id: tags
        type: string_map
      - id: tiles_type
        type: string_array
      - id: tiles_num
        type: s4
      - id: tiles
        type: tile
        repeat: expr
        repeat-expr: tiles_num
      - id: unknown
        size-eos: true
  string_map:
    seq:
      - id: size
        type: u1
      - id: entries
        type: string_map_kv_set
        repeat: expr
        repeat-expr: size
  string_map_kv_set:
    seq:
      - id: key_len
        type: u2
      - id: key
        size: key_len
        encoding: utf8
        type: str
      - id: value_len
        type: u2
      - id: value
        size: value_len
        type: str
        encoding: utf8
  string_array:
    seq:
      - id: size
        type: u1
      - id: entries
        type: string
        repeat: expr
        repeat-expr: size
  string:
    seq:
      - id: a
        type: u2
      - id: b
        type: u2
        if: a >> 15 == 1
      - id: c
        type: u2
        if: a >> 13 == 7
      - id: value
        type: str
        encoding: utf8
        size: '(a>>13==7) ? (((a & 0x0F) << 12) | ((b & 0x3F) << 6) | (c & 0x3F) ) : ((a >> 13 == 6)? (((a& 0x1F) << 6) | (b & 0x3F)) : a )'
    instances:
      size:
        value: '(a>>13==7) ? (((a & 0x0F) << 12) | ((b & 0x3F) << 6) | (c & 0x3F) ) : ((a >> 13 == 6)? (((a& 0x1F) << 6) | (b & 0x3F)) : a )'
  tile:
    seq:
      - id: type
        type: u1
      - id: position
        type: s4
      - id: config
        type: config
      - id: rotation
        type: s1
    instances:
      x:
        value: position >> 16
      y:
        value: position & 0xFFFF
  config:
    seq:
      - id: type
        type: u1
        enum: config_type
      - id: config
        type:
          switch-on: type
          cases:
            # 0: null
            1: s4
            2: s8 # maybe not corrent
            3: f4
            4: config_string
            5: content_id
            6: int_array # not test yet
            7: point
            8: point2s
            # 9: tech_tree not impletment
            10: b1
            11: f8 #not test yet
            # 12 box not implement
            #13: LAccesss not implement
            14: config_bytes
            # 15: UnitCommands not implement
            #16 bool_array not implement
            
  config_string:
    seq:
      - id: exist
        type: u1
      - id: value
        type: string
  config_bytes:
    seq:
      - id: len
        type: s4
      - id: bytes
        size: len
  point:
    seq:
      - id: x
        type: s4
      - id: y
        type: s4
  point2:
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
  point2s:
    seq:
      - id: num
        type: u1
      - id: point2
        type: point2
        repeat: expr
        repeat-expr: num
  content_id:
    seq:
      - id: type_id
        type: u1
      - id: id
        type: u2
  int_array: # not test yes
    seq:
      - id: size
        type: s2
      - id: values
        repeat: expr
        repeat-expr: size
        type: s4
enums:
  known_version:
    0: undone
    1: current
  config_type:
    0: 'null'
    1: 'int'
    2: 'long'
    3: 'float'
    4: 'string'
    5: 'id'
    6: 'int_array'
    7: 'point'
    8: 'points'
    9: 'techtree' # not implement
    10: 'bool'
    11: 'double'
    12: 'building_or_buildingbox'
    13: 'logic'
    14: 'bytes'
    15: 'unit_commands'
    16: 'bools'