use crate::*;
use core::default::Default;

impl_packed_struct! {
    pub struct sgx_basename_t {
        pub name: [uint8_t; 32],
    }
}

pub const SGX_REPORT_BODY_RESERVED1_BYTES: size_t = 12;
pub const SGX_REPORT_BODY_RESERVED2_BYTES: size_t = 32;
pub const SGX_REPORT_BODY_RESERVED3_BYTES: size_t = 32;
pub const SGX_REPORT_BODY_RESERVED4_BYTES: size_t = 42;

pub type sgx_misc_select_t = uint32_t;
pub type sgx_prod_id_t = uint16_t;
pub type sgx_config_svn_t = uint16_t;

pub const SGX_ISVEXT_PROD_ID_SIZE: size_t = 16;
pub type sgx_isvext_prod_id_t = [uint8_t; SGX_ISVEXT_PROD_ID_SIZE];

pub const SGX_CONFIGID_SIZE: size_t = 64;
pub type sgx_config_id_t = [uint8_t; SGX_CONFIGID_SIZE];

pub const SGX_ISV_FAMILY_ID_SIZE: size_t = 16;
pub type sgx_isvfamily_id_t = [uint8_t; SGX_ISV_FAMILY_ID_SIZE];

pub const SGX_REPORT_DATA_SIZE: size_t = 64;

impl_copy_clone! {
    pub struct sgx_report_data_t {
        pub d: [uint8_t; SGX_REPORT_DATA_SIZE],
    }

    pub struct sgx_report_body_t {
        pub cpu_svn: sgx_cpu_svn_t,
        pub misc_select: sgx_misc_select_t,
        pub reserved1: [uint8_t; SGX_REPORT_BODY_RESERVED1_BYTES],
        pub isv_ext_prod_id: sgx_isvext_prod_id_t,
        pub attributes: sgx_attributes_t,
        pub mr_enclave: sgx_measurement_t,
        pub reserved2: [uint8_t; SGX_REPORT_BODY_RESERVED2_BYTES],
        pub mr_signer: sgx_measurement_t,
        pub reserved3: [uint8_t; SGX_REPORT_BODY_RESERVED3_BYTES],
        pub config_id: sgx_config_id_t,
        pub isv_prod_id: sgx_prod_id_t,
        pub isv_svn: sgx_isv_svn_t,
        pub config_svn: sgx_config_svn_t,
        pub reserved4: [uint8_t; SGX_REPORT_BODY_RESERVED4_BYTES],
        pub isv_family_id: sgx_isvfamily_id_t,
        pub report_data: sgx_report_data_t,
    }
}

pub type sgx_epid_group_id_t = [uint8_t; 4];
pub type sgx_isv_svn_t = uint16_t;

impl_packed_copy_clone! {
    pub struct sgx_quote_t {
        pub version: uint16_t,                    /* 0   */
        pub sign_type: uint16_t,                  /* 2   */
        pub epid_group_id: sgx_epid_group_id_t,   /* 4   */
        pub qe_svn: sgx_isv_svn_t,                /* 8   */
        pub pce_svn: sgx_isv_svn_t,               /* 10  */
        pub xeid: uint32_t,                       /* 12  */
        pub basename: sgx_basename_t,             /* 16  */
        pub report_body: sgx_report_body_t,       /* 48  */
        pub signature_len: uint32_t,              /* 432 */
        pub signature: [uint8_t; 0],              /* 436 */
    }
}

impl_struct_default! {
    sgx_quote_t; //436
    sgx_report_data_t; //64
}

impl_struct_ContiguousMemory! {
    sgx_quote_t;
    sgx_report_data_t;
}

pub const SGX_CPUSVN_SIZE: size_t = 16;
pub const SGX_HASH_SIZE: size_t = 32;
impl_struct! {
    pub struct sgx_cpu_svn_t {
        pub svn: [uint8_t; SGX_CPUSVN_SIZE],
    }

    pub struct sgx_attributes_t {
        pub flags: uint64_t,
        pub xfrm: uint64_t,
    }

    pub struct sgx_measurement_t {
        pub m: [uint8_t; SGX_HASH_SIZE],
    }
}
