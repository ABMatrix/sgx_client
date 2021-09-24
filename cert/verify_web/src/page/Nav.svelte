<script lang="ts">
  import { tab } from "../store";
  let open: string;
  tab.subscribe((value) => (open = value));
  function changeTab(name: string): void {
    tab.set(name);
  }

  let logo = "https://www.safematrix.io/_nuxt/img/logo.7234db3.png";
</script>

<div class="shadow w-full fixed px-8">
  <nav class="flex flex-row h-full justify-between">
    <!-- <a href="http://safematrix.io">
      <img
        src={logo}
        class="w-100 h-12 object-cover my-auto"
        alt="Safematrix"
      />
    </a> -->
    <div class="text-xl my-auto ">SGX 证书验证</div>
    <div class="flex flex-row justify-items-center space-x-4 my-4">
      <div
        class="text-xl my-auto cursor-pointer hover:text-blue-400 active:underline {open ===
        'manage'
          ? 'underline text-blue-400'
          : ''}"
        on:click={() => window.open('https://github.com/ABMatrix/sgx_client')}
      >
        Github
      </div>
    </div>
  </nav>
</div>
