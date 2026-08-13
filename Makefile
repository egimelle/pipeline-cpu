IVERILOG := iverilog
VVP      := vvp
BUILD    := build

CORE     := source/core/alu.v source/core/alu_control.v source/core/control_unit.v \
            source/core/data_memory.v source/core/imm_gen.v source/core/instruction_memory.v \
            source/core/pc.v source/core/register_file.v
PIPELINE := $(CORE) $(wildcard source/pipeline/*.v)
SINGLE_CYCLE := $(CORE) source/examples/single_cycle/top.v

.PHONY: all test test-unit test-pipeline test-single-cycle clean \
        alu alu_control control_unit pc_im regfile_immgen hazard_detection forwarding_unit \
        pipeline flush regression single_cycle

all: test

$(BUILD):
	mkdir -p $(BUILD)

# ---- unit tests (source/core + standalone pipeline blocks) ----
alu: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/alu_tb source/core/alu.v tb/unit/alu_tb.v
	cd $(BUILD) && $(VVP) alu_tb

alu_control: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/alu_control_tb source/core/alu_control.v tb/unit/alu_control_tb.v
	cd $(BUILD) && $(VVP) alu_control_tb

control_unit: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/control_unit_tb source/core/control_unit.v tb/unit/control_unit_tb.v
	cd $(BUILD) && $(VVP) control_unit_tb

pc_im: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/pc_im_tb source/core/pc.v source/core/instruction_memory.v tb/unit/pc_im_tb.v
	cd $(BUILD) && $(VVP) pc_im_tb

regfile_immgen: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/regfile_immgen_tb source/core/register_file.v source/core/imm_gen.v tb/unit/regfile_immgen_tb.v
	cd $(BUILD) && $(VVP) regfile_immgen_tb

hazard_detection: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/hazard_detection_tb source/pipeline/hazard_detection.v tb/unit/hazard_detection_tb.v
	cd $(BUILD) && $(VVP) hazard_detection_tb

forwarding_unit: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/forwarding_unit_tb source/pipeline/forwarding_unit.v tb/unit/forwarding_unit_tb.v
	cd $(BUILD) && $(VVP) forwarding_unit_tb

test-unit: alu alu_control control_unit pc_im regfile_immgen hazard_detection forwarding_unit

# ---- full 5-stage pipeline ----
pipeline: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/top_pipeline_tb $(PIPELINE) tb/pipeline/top_pipeline_tb.v
	cd $(BUILD) && $(VVP) top_pipeline_tb

flush: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/top_pipeline_flush_tb $(PIPELINE) tb/pipeline/top_pipeline_flush_tb.v
	cd $(BUILD) && $(VVP) top_pipeline_flush_tb

regression: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/regression_tb $(PIPELINE) tb/pipeline/regression_tb.v
	cd $(BUILD) && $(VVP) regression_tb

test-pipeline: pipeline flush regression

# ---- single-cycle reference design ----
single_cycle: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/top_tb $(SINGLE_CYCLE) tb/examples/single_cycle/top_tb.v
	cd $(BUILD) && $(VVP) top_tb

test-single-cycle: single_cycle

test: test-unit test-pipeline test-single-cycle

clean:
	rm -rf $(BUILD)
