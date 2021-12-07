import * as wasm from "../../../pkg";
import { PEMObject } from "pem-ts";
import moment from "moment";

export function valid(pemString: string) {
  try {
    const pem: PEMObject = new PEMObject();
    pem.decode(pemString);
    console.log(pem.label);
  } catch (e) {}
}
export async function verify(pemString: string) {
  await wasm.default();

  const pem: PEMObject = new PEMObject();
  pem.decode(pemString);
  console.log(pem.label);
  const der = buf2hex(pem.data);
  console.log(der);
  const timestamp = moment().valueOf();
  try {
    const result = wasm.verify_mra_cert_str(der, BigInt(timestamp));
    return JSON.parse(result);
  } catch (e) {
    console.log(e)
    return "";
  }
}

function buf2hex(buffer) {
  return [...new Uint8Array(buffer)]
    .map((x) => x.toString(16).padStart(2, "0"))
    .join("");
}
