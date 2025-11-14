<script>
import axios from 'axios';

export default {
  data() {
    return {
      airplanes: []
    }
  },

  mounted() {
    this.getAirplanes()
  },

  methods: {
    getAirplanes() {
      axios.get('http://localhost:8080/planes')
        .then(res => (this.airplanes = res.data))
    }
  }
}
</script>

<template>
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
