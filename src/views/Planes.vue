<script setup>
import {ref, onMounted } from 'vue'
import axios from 'axios';
import { useRouter } from 'vue-router'

import Header from '@/components/Header.vue';
import Footer from '@/components/Footer.vue';

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
  router.push({name: 'PlaneInfo', params: {id: plane.id}})
}

function handleImageError(event) {
  event.target.src = '/plane-example.jpg';
}

onMounted(() => {
  getAirplanes()
})
</script>

<template>
  <body class="page">
    <Header/>
    <main class="main">
        <h1 class="main__h1"> Наши самолёты</h1>
        <section class="cards">
            <ul class="cards-list">
                <li class="card" v-for="plane in airplanes" :key="plane.id">
                    <img 
                      :src="`/plane${plane.id}.jpg`" 
                      :alt="plane.name" 
                      class="plane-image"
                      @error="handleImageError"
                    >
                    <h3 class="cards__title">{{ plane.name }}</h3>
                    <h3 class="cards__title">{{ plane.isAvailable ? 'Свободен' : 'Занят' }}</h3>
                    <button class="card__button" @click="goToPlaneInfo(plane)"> Подробнее </button>
                </li>
            </ul>
        </section>
    </main>
  </body>
  <Footer></Footer>
</template>

<style scoped>
.main {
  margin-top: 50px;
  margin-bottom: 50px;
}

.main__h1 {
  text-align: center;
  text-transform: uppercase;
  font-weight: 600;
  color: #fff;
}

.cards {
  margin: 40px 30px;
}

.cards-list {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 25px;
}

.card {
  display: grid;
  grid-template-rows: auto 1fr auto;
  height: 100%;
  border: 2px solid #1E90FF;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 8px 25px rgba(30, 144, 255, 0.15);
  transition: all 0.3s ease;
  color: #2A5298;
  background-color: #fff;
}

.card:hover {
  transform: scale(1.02);
}

.card__button {
  cursor: pointer;
  width: 200px;
  height: 40px;
  border-radius: 8px;
  margin: 15px auto;
  display: block;
  background-color: #1E3C72;
  color: white;
  border: 1px solid #87CEEB;
}

.cards__title {
  font-size: 18px;
  padding: 15px;
  display: flex;
  align-items: center;
  min-height: 80px;
  font-style: italic;
}

.plane-image {
  width: 100%;
  height: 250px;
  object-fit: cover;
  display: block;
}
.error {
  display: flex;
  justify-content: center;
}
</style>