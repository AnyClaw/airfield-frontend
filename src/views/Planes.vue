<script setup>
import {ref, onMounted } from 'vue'
import axios from 'axios';

import Header from '@/components/Header.vue';

const airplanes = ref([])

const getAirplanes = async () => {
  try {
    const response = await axios.get('http://localhost:8080/planes', {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('authToken')}`
      }
    })
    airplanes.value = response.data
  } catch (error) {
    alert(error)
  }
}

onMounted(() => {
  getAirplanes()
  console.log(localStorage.getItem('authToken'))
})
</script>

<template>
  <Header />

  <div class="planes">
    <div class="plane-card" v-for="plane in airplanes" :key="plane.id">
      {{ plane.name }}
    </div>
  </div>
</template>

<style scoped>
.planes {
  margin: 50px 10%;
  padding: 20px;
  background-color: white;
  border: 5px solid silver;
  border-radius: 20px;
}

.plane-card {
  margin-bottom: 20px;
  padding: 5px;
  border: 2px solid silver;
}
</style>