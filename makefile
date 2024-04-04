# Compiler and Linker
CXX := g++
# Compiler and linker flags
# CXXFLAGS := -std=c++17 -Wall -Wextra -Werror -Og -g -pipe -Wall -fPIC -MMD -MP
#CXXFLAGS := -std=c++17 -Wall -Wextra -Og -g -pipe -fPIC -MMD -MP
CXXFLAGS := -std=c++17 -Wall -O0 -g -pipe -fPIC -MMD -MP

CXXLDFLAGS := #

# artifacts structure and sources
PROJECT_DIR :=$(CURDIR)
MAIN_DIR    :=$(PROJECT_DIR)/src
OBJECTS_DIR :=$(PROJECT_DIR)/objects
BIN_DIR     :=$(PROJECT_DIR)/bin

# targets
MAIN_TARGET_BASENAME :=main
MAIN_TARGET :=$(BIN_DIR)/$(MAIN_TARGET_BASENAME).exe

# make folder if not created
define WIN_MKDIR
$(shell powershell -Command "if (-not (Test-Path $(1))) { New-Item $(1) -Type Directory }")
endef
_MK_DIRS := $(call WIN_MKDIR, $(OBJECTS_DIR)) \
            $(call WIN_MKDIR, $(BIN_DIR))

define FIND_DIRS
$(shell powershell -Command "(Get-ChildItem -Path $(1) -Recurse -Directory | ForEach-Object { $$_.FullName }) -join ':' -replace '\\','/'")
endef

VPATH :=$(PROJECT_DIR):\
        $(MAIN_DIR):\
        $(call FIND_DIRS, $(MAIN_DIR)):\
        $(OBJECTS_DIR)\

JSON_INC    :=D:\Cpp\json\include
JSON_FLAGS  :=-I$(JSON_INC)

PYTHON_INC    :='C:\Program Files\Python311\include'
#PYTHON_INC     :=C:\msys64\mingw64\include\python3.11
PYTHON_FLAGS   :=-I$(PYTHON_INC)
PYTHON_LIB     :='C:\Program Files\Python311'
#PYTHON_LIB     :=C:\msys64\mingw64\bin
PYTHON_LDFLAGS :=-Wl,-rpath,$(PYTHON_LIB) -L$(PYTHON_LIB)
#PYTHON_LIBS    :=-lpython3.11
PYTHON_LIBS    :=-lpython311

BOOST_INC     :=D:\Cpp\boost_1_83_0_install\include\boost-1_83
BOOST_FLAGS   :=-I$(BOOST_INC)
BOOST_LIB     :=D:\Cpp\boost_1_83_0_install\lib
BOOST_LDFLAGS :=-Wl,-rpath,$(BOOST_LIB) -L$(BOOST_LIB)
BOOST_LIBS    :=-lboost_filesystem-mgw13-mt-x64-1_83 \
                -lboost_thread-mgw13-mt-x64-1_83 \
                -lboost_python311-mgw13-mt-x64-1_83

CXXFLAGS   +=-I$(MAIN_DIR) \
              $(JSON_FLAGS) \
              $(BOOST_FLAGS) \
              $(PYTHON_FLAGS)

CXXLDFLAGS +=$(BOOST_LDFLAGS) $(BOOST_LIBS) \
             $(PYTHON_LDFLAGS) $(PYTHON_LIBS)

# cpp src
define RWILDCARD
$(foreach d,$(wildcard $(1:=/*)),$(call RWILDCARD,$(d),$(2))$(filter $(subst *,%,$(2)),$(d)))
endef

SOURCES_CPP      := $(call RWILDCARD,$(MAIN_DIR),*.cpp)
OBJECTS_CPP      := $(addprefix $(OBJECTS_DIR)/,$(notdir $(SOURCES_CPP:.cpp=.o)))

MAIN_CPP         := $(filter-out ,$(SOURCES_CPP))
MAIN_CPP_OBJECTS := $(addprefix $(OBJECTS_DIR)/,$(notdir $(MAIN_CPP:.cpp=.o)))

.PHONY: all info clean run

all: $(MAIN_TARGET) $(LUA_MOD) $(LUA_PACKAGE)

$(MAIN_TARGET): $(MAIN_CPP_OBJECTS)
	$(CXX) -o $@ $^ $(CXXLDFLAGS)

$(OBJECTS_DIR)/%.o:%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

info:
	@echo "[ $(VPATH) ]"

define RM_RFV # yes I know this is cursed but no "$> rm -prv" on windows
    @powershell -Command "\
    $$file=\"$(1)\";\
    if (-not (Test-Path -Path $$file)) {\
        Write-Host \"does not not exits: $$file\" -ForegroundColor Yellow;\
    } else {\
        Get-ChildItem -Path $$file| ForEach-Object {\
            if (Test-Path -Path $$_.FullName) {\
                Write-Host \"Removing: $$_\" -Foreground Red;\
                Remove-Item -Path $$_.FullName -Force;\
            } else {\
                Write-Host \"does not not exits: $$_\" -Foreground Yellow;\
            }\
        }\
    }\
"
endef
clean:
	$(call RM_RFV,$(OBJECTS_DIR)/*)
	$(call RM_RFV,$(MAIN_TARGET))

run:
	@powershell $(MAIN_TARGET)

DEPENDENCIES :=$(wildcard $(OBJECTS_DIR)/*.d)
-include $(DEPENDENCIES)
