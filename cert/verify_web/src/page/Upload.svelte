<script>
  import { shortPem, verify } from "../api";
  import { toast } from "@zerodevx/svelte-toast";
  let file;
  let upload = false;
  let verified = false;
  let pem;
  let report;

  function onChange(e) {
    upload = true;
    file = e.target.files[0];
    uploadFiles(file);
  }

  function getFileSize(file) {
    return file.size > 1024
      ? file.size > 1048576
        ? Math.round(file.size / 1048576) + "mb"
        : Math.round(file.size / 1024) + "kb"
      : file.size + "b";
  }

  function uploadFiles() {
    if (file) {
      const reader = new FileReader();
      reader.addEventListener("load", (event) => {
        pem = event.target.result;
      });
      reader.readAsText(file);
    }
  }

  async function verifyCert() {
    let result = await verify(pem);
    console.log(result.result);
    if (result.result === "Success") {
      report = result.report_body;
    }
    verified = true;
  }

  function clearPem() {
    verified = false;
    pem = undefined;
    file = undefined;
  }
</script>

<section class="max-w-4xl mx-auto px-4 pt-24">
  <div class="flex flex-col space-y-4">
    <div class="w-full shadow-inner rounded-md bg-blue-100 p-4">
      <article
        aria-label="File Upload Modal"
        class="relative h-full flex flex-col "
        ondrop="dropHandler(event);"
        ondragover="dragOverHandler(event);"
        ondragleave="dragLeaveHandler(event);"
        ondragenter="dragEnterHandler(event);"
      >
        <!-- scroll area -->
        <section class="h-full overflow-auto p-8 w-full flex flex-col">
          {#if pem == null}
            <header
              class="border-dashed border-2 border-gray-400 py-12 flex flex-col justify-center items-center"
            >
              <p
                class="mb-3 font-semibold text-gray-900 flex flex-wrap justify-center"
              >
                <span>上传证书文件</span>
              </p>
              <input
                id="hidden-input"
                bind:this={upload}
                type="file"
                on:change={onChange}
                class="hidden"
              />
              <button
                id="button"
                on:click={upload.click()}
                class="mt-2 rounded-md px-3 py-1 bg-gray-200 hover:bg-gray-300 focus:shadow-outline focus:outline-none"
              >
                Upload a file
              </button>
            </header>
          {:else}
            <div
              class="text-yellow-600 border-dashed border-2 border-gray-400 py-4 flex flex-col justify-start items-start p-8"
            >
            <div class="text-yellow-600">-----BEGIN CERTIFICATE-----</div>
              {@html shortPem(pem)}
            <div class="text-yellow-600">-----END CERTIFICATE-----</div>
            </div>
          {/if}

          <!-- sticky footer -->
          <footer class="flex justify-center px-8 pb-8 pt-8">
            {#if verified === false}
              <button
                type="button"
                on:click={verifyCert}
                disabled={pem == null}
                class="rounded-md px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white w-40 h-10 focus:shadow-outline focus:outline-none"
              >
                点击验证
              </button>
            {:else}
              <button
                type="button"
                on:click={clearPem}
                disabled={pem == null}
                class="rounded-md px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white w-40 h-10 focus:shadow-outline focus:outline-none"
              >
                重新上传
              </button>
            {/if}
          </footer>
        </section>
      </article>
    </div>
  </div>
  <section class="py-10 ">
    <div>常见问题</div>
    <ul>
      <li>
        <div>Sgx 服务器安全在哪里？</div>
        <div />
      </li>
      <li>
        <div>Sgx 证书验证过程？</div>
      </li>
    </ul>
  </section>
</section>
