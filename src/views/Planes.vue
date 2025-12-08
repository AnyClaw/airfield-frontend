<script setup>
import {ref, onMounted } from 'vue'
import axios from 'axios';
import { useRouter } from 'vue-router'

import Header from '@/components/Header.vue';

const airplanes = ref([])
const isError = ref(false)

const router = useRouter()

async function getAirplanes() {
  try {
    const response = await axios.get('http://localhost:8080/planes', {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('authToken')}`
      }
    })
    airplanes.value = response.data
    isError.value = false
  } catch (error) {
    isError.value = true
  }
}

async function goToPlaneInfo(plane) {
  // const data = JSON.stringify(plane)
  router.push({name: 'PlaneInfo', params: {id: plane.id}})
}

onMounted(() => {
  getAirplanes()
})
</script>

<template>
  <Header/>

  <div class="planes">
    <div v-if="!isError" class="plane-card" v-for="plane in airplanes" :key="plane.id">
      <div @click="goToPlaneInfo(plane)">{{ plane.name }}</div>
    </div>

    <div v-else class="error">Сервер временно недоступен</div>
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
  cursor: pointer;
}

.error {
  display: flex;
  justify-content: center;
}
</style>