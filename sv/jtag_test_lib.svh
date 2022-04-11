// `include "jtag_simple_test.svh"
// `include "jtag_if.svh"
class jtag_test extends uvm_test;
  
  jtag_env env;

  // virtual interface
  jtag_vif jtag_virtual_if;
    
  //  interface proxy
  jtag_if_proxy if_proxy;
  
  extern function void check_vif();
  extern function void check_if_proxy();
  
  `uvm_component_utils(jtag_test)
  
  function new (string name = "jtag_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction // new
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("JTAG_TEST_INFO", "Build phase", UVM_LOW)
    env = jtag_env::type_id::create("env",this);
  endfunction // build_phase
  
endclass // jtag_test

// check_vif
function void jtag_test::check_vif();
  if (!uvm_config_db#(jtag_vif)::get(null,get_full_name(),"jtag_virtual_if", jtag_virtual_if))
    begin
      `uvm_fatal("JTAG_TEST_FATAL", {"VIF must exist for: ", get_full_name()})
    end
  else
    uvm_config_db#(jtag_vif)::set(this,"*","jtag_virtual_if", jtag_virtual_if);
  
endfunction // check_vif


// check_if_proxy
function void jtag_test::check_if_proxy();
  if (!uvm_config_db#(jtag_if_proxy)::get(null,get_full_name(),"jtag_if_proxy", if_proxy))
    begin
      `uvm_fatal("JTAG_TEST_FATAL", {"IF_PROXY must exist for: ", get_full_name()})
    end
  else
    uvm_config_db#(jtag_if_proxy)::set(this,"*","jtag_if_proxy", if_proxy);
  
endfunction // check_if_proxy

// jtag_simple_test
class jtag_simple_test extends jtag_test;
  
    jtag_simple_sequence jtag_simple_seq;
 
  `uvm_component_utils_begin(jtag_simple_test)
  `uvm_field_object(jtag_simple_seq, UVM_DEFAULT)
  `uvm_component_utils_end
  
  function new (string name = "jtag_simple_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction // new
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("JTAG_SIMPLE_TEST", "Build phase ", UVM_LOW)
    jtag_agent_config::type_id::set_type_override(jtag_agent_config_active::get_type());    
    check_vif();
    check_if_proxy();
  endfunction // build_phase
  
  virtual task run_phase (uvm_phase phase);   
    super.run_phase(phase);
    phase.raise_objection(this,"Jtag test raised objection");    
    uvm_test_done.raise_objection(this,"Jtag test raised uvm_test_done objection");
    jtag_simple_seq = jtag_simple_sequence::type_id::create("jtag_simple_seq");
    jtag_simple_seq.start(env.jtag_agnt.sequencer);
    `uvm_info("JTAG SIMPLE TEST", "After seq start", UVM_LOW)
    uvm_test_done.drop_objection(this,"Jtag test dropped uvm_test_done objection");   
    phase.drop_objection(this, "Jtag test dropped objection");
  endtask // run_phase
  
endclass // jtag_simple_test

// read idcode test
class jtag_idcode_rd_test extends jtag_simple_test;
  
  // `uvm_component_utils(jtag_idcode_rd_test)
  `uvm_component_utils_begin(jtag_idcode_rd_test)
  `uvm_field_object(jtag_simple_seq, UVM_DEFAULT)
  `uvm_component_utils_end
  
  function new (string name = "jtag_idcode_rd_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction // new
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("JTAG_IDCODE_RD_TEST", "Build phase ", UVM_LOW)

    // specify agent configuration type
    // jtag_agent_config::type_id::set_type_override(jtag_agent_config_active::get_type());

    // specify sequence item type
    jtag_send_packet::type_id::set_type_override(jtag_idcode::get_type());
    
    // specify default sequence type
    // uvm_config_db#(uvm_object_wrapper)::set(this,"*sequencer.run_phase", "default_sequence", jtag_simple_sequence::type_id::get());
    
    // specify sequence type
    jtag_simple_sequence::type_id::set_type_override(jtag_simple_sequence_with_rand_delay::get_type());

    // automatic configuration
    uvm_config_int::set(this,"*", "coverage_enable", 1);
    uvm_config_int::set(this,"*", "drv_mon_tx_check_en", 1);

  endfunction // build_phase
    
endclass // jtag_idcode_rd
