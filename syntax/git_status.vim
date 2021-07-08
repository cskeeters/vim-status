if exists("b:current_syntax")
   echo "finishing"
   finish
endif

syn region fileMod start=/\vmodified: / end=+$+ oneline
syn region fileUnk start=/\v^\? / end=+$+ oneline
syn region fileDel start=/\vdeleted: / end=+$+ oneline

hi default link fileMod Directory
hi default link fileAdd String
hi default link fileDel Character
hi default link fileUnk Type
